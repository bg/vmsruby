#
# How to use:
#
# db = PStore.new("/tmp/foo")
# db.transaction do
#   p db.roots
#   ary = db["root"] = [1,2,3,4]
#   ary[0] = [1,1.5]
# end

# db.transaction do
#   p db["root"]
# end

require "fileutils"
require "digest/md5"

# ODS-2 does not allow multiple dots in filenames, so suffix
# with underscore instead.
# - FixMe: ideally we would change the final dot in the basename to an
#   underscore and leave the dot in the suffix alone, but as of
#   06-Jun-2008, basename doesn't work with VMS filepaths; there is a
#   workaround for this in our util.rb, but it *breaks* basename on Unix
#   filepaths and we need to handle both.
def suffix_filename filename,suffix
  filename+suffix.sub(/\./,'_')
end

class PStore
  class Error < StandardError
  end

  def initialize(file)
    dir = File::dirname(file)
    unless File::directory? dir
      raise PStore::Error, format("directory %s does not exist", dir)
    end
    if File::exist? file and not File::readable? file
      raise PStore::Error, format("file %s not readable", file)
    end
    @transaction = false
    @filename = file
    @abort = false
  end

  def in_transaction
    raise PStore::Error, "not in transaction" unless @transaction
  end
  def in_transaction_wr()
    in_transaction()
    raise PStore::Error, "in read-only transaction" if @rdonly
  end
  private :in_transaction, :in_transaction_wr

  def [](name)
    in_transaction
    @table[name]
  end
  def fetch(name, default=PStore::Error)
    unless @table.key? name
      if default==PStore::Error
	raise PStore::Error, format("undefined root name `%s'", name)
      else
	default
      end
    end
    self[name]
  end
  def []=(name, value)
    in_transaction_wr()
    @table[name] = value
  end
  def delete(name)
    in_transaction_wr()
    @table.delete name
  end

  def roots
    in_transaction
    @table.keys
  end
  def root?(name)
    in_transaction
    @table.key? name
  end
  def path
    @filename
  end

  def commit
    in_transaction
    @abort = false
    throw :pstore_abort_transaction
  end
  def abort
    in_transaction
    @abort = true
    throw :pstore_abort_transaction
  end

  def transaction(read_only=false)
    raise PStore::Error, "nested transaction" if @transaction
    begin
      @rdonly = read_only
      @abort = false
      @transaction = true
      value = nil
      new_file = suffix_filename @filename,".new"

      content = nil
      unless read_only
	exists=File.exists? @filename
        $VMS_FILE_MODE='shr=get,put'
	file = (exists ?
		File.open(@filename,'r+') :
		File.open(@filename,'w+')).binmode
        file.write_mode=:FWRITE
# FixMe: disabled until VMS file locking is fixed
#   - In testing, the lock was never released after the
#     file was closed.
#       file.flock(File::LOCK_EX)
        commit_new(file) if FileTest.exist?(new_file)
        content = file.read()
      else
        begin
          $VMS_FILE_MODE='shr=get,put'
          file = File.open(@filename, 'r').binmode
# FixMe: disabled until VMS file locking is fixed
#   - We didn't test read_only mode, but we assume it has the
#     same problem with locks not being relieved upon close.
#         file.flock(File::LOCK_SH)
          content = (File.read(new_file) rescue file.read())
        rescue Errno::ENOENT
          content = ""
        end
      end

      if content != ""
	@table = load(content)
        if !read_only
          size = content.size
          md5 = Digest::MD5.digest(content)
        end
      else
	@table = {}
      end
      content = nil		# unreference huge data

      begin
	catch(:pstore_abort_transaction) do
	  value = yield(self)
	end
      rescue Exception
	@abort = true
	raise
      ensure
	if !read_only and !@abort
          tmp_file = suffix_filename @filename,".tmp"
	  content = dump(@table)
	  if !md5 || size != content.size || md5 != Digest::MD5.digest(content)
            File.open(tmp_file, "w") {|t|
              t.binmode
              t.write_mode=:FWRITE
              t.write(content)
            }
            File.rename(tmp_file, new_file)
            commit_new(file)
          end
          content = nil		# unreference huge data
	end
      end
    ensure
      @table = nil
      @transaction = false
      file.close if file
    end
    value
  end

  def dump(table)
    Marshal::dump(table)
  end

  def load(content)
    Marshal::load(content)
  end

  def load_file(file)
    Marshal::load(file)
  end

  private
  def commit_new(f)
    f.truncate(0)
    f.rewind
    new_file = suffix_filename @filename,".new"
    File.open(new_file) do |nf|
      nf.binmode
      nf.write_mode=:FWRITE
      FileUtils.copy_stream(nf, f)
    end
    File.unlink(new_file)
  end

end

if __FILE__ == $0
  db = PStore.new("/tmp/foo")
  db.transaction do
    p db.roots
    ary = db["root"] = [1,2,3,4]
    ary[1] = [1,1.5]
  end

  1000.times do
    db.transaction do
      db["root"][0] += 1
      p db["root"][0]
    end
  end

  db.transaction(true) do
    p db["root"]
  end
end
