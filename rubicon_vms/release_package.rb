# purpose:
# build a release: tgz, zip.
#
# depends on:
# zip   (infozip-version)
# tar   (gnu-version)
#
require 'fileutils'
require 'find'

class ReleaseBuilder
	def initialize
		@release_name = nil
		@release_version = nil
		@populate_dir = nil
	end
	attr_accessor :release_name, :release_version, :populate_dir
	def self.mk_release(&block)
		rel = ReleaseBuilder.new
		block.call(rel)
		rel.execute
	end
	def assign_defaults
		@release_name ||= "noname-0.1"
		@release_version ||= "0.1"
		@populate_dir ||= lambda{}
	end
	def execute
		assign_defaults
		make_tarball
		puts "DONE"
	end
	def make_dir(&block)
		dir_orig = FileUtils.pwd
		dir_rel = File.join(dir_orig, @release_name)
		if FileTest.directory?(dir_rel)
			FileUtils.rm_rf(dir_rel)
		end
		FileUtils.mkdir(dir_rel)
		@populate_dir.call(dir_rel)
		block.call(dir_rel)
		FileUtils.cd(dir_orig)
		FileUtils.rm_rf(dir_rel)
	end
	def filenames(dir)
		FileUtils.cd(dir)
		result = []
		Find.find(".") do |path|
			if FileTest.directory?(path)
				next
			else
				path.slice!(0, 2)  # remove prefix "./"
				result << path
			end
		end
		result.sort
	end
	def create_manifest_file(dir)
		result = filenames(dir) + ["MANIFEST"]
		manifest = result.sort.join("\n")+"\n" 
		File.open("MANIFEST", "w") { |f| f.write manifest }
	end
	def make_tarball
		toolsdir = FileUtils.pwd
		make_dir do |destdir|
			#FileUtils.cp(File.join(toolsdir, "install.rb"), destdir)
			#create_manifest_file(destdir)
			FileUtils.cd(toolsdir)
			puts "creating .tar.gz"
			system("tar czfv #{@release_name}.tar.gz #{@release_name}")
			puts "creating .zip"
			system("zip -r #{@release_name}.zip #{@release_name}")
		end
	end
end

def find_unnecessary_files(dir)
	FileUtils.cd(dir)
	files = Dir.entries(".")  # all files in the dir.. including dotfiles
	files.slice!(0, 2)  # remove "." and "..", so we don't kill em!
	files.map!{|file| dir+"/"+file}

	kill, keep = files.partition{|file|
		# files to be excluded
		file =~ /CVS$|status$/
	}
	keep, kill2 = keep.partition{|file|
		# files to be included
		file =~ /\.rb$|regexp\.test$/
	}
	[keep, kill+kill2]
end

def copy_files(sourcedir, destdir)
	# copy builtin
	dir_builtin = File.join(destdir, "builtin")
	FileUtils.mkdir(dir_builtin)
	FileUtils.cp_r(File.join(sourcedir, "builtin", "."), dir_builtin)

	# copy language
	dir_language = File.join(destdir, "language")
	FileUtils.mkdir(dir_language)
	FileUtils.cp_r(File.join(sourcedir, "language", "."), dir_language)

	# copy util
	dir_util = File.join(destdir, "util")
	FileUtils.mkdir(dir_util)
	FileUtils.cp_r(File.join(sourcedir, "util", "."), dir_util)

	# remove unnessary files
	keep, kill   = find_unnecessary_files(dir_builtin)
	keep2, kill2 = find_unnecessary_files(dir_language)
	keep3, kill3 = find_unnecessary_files(dir_util)
	keep += keep2 + keep3
	kill += kill2 + kill3
	kill.each { |file| FileUtils.rm_rf(file) } 

	# copy misc files
	FileUtils.cd(sourcedir)
	files = %w(
		AllTests.rb
		COPYING
		ChangeLog
		GNUmakefile
		Makefile
		README
		post.rb
		result_ascii.rb
		result_xml.rb
		result_yaml.rb
		rubicon.rb
		rubicon_tests.rb
		rubicon_xmarshal.rb
	)
	FileUtils.cp(files, destdir)
end

if $0 == __FILE__
	VER = "0.36"
	sourcedir = File.join(FileUtils.pwd, ".")
	ReleaseBuilder.mk_release do |rel|
		rel.release_name = "rubytests-#{VER}"
		rel.release_version =  VER
		rel.populate_dir = lambda do |dirname|
			copy_files(sourcedir, dirname)
		end
	end
end
