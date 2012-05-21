#!/usr/bin/env ruby -Ku

def grep_a_file(path, file, pattern)
#p file
    line_number = 0
    File.open(file, "r") { |fd|
        fd.each_line do |line|
#p line
begin
			if Regexp.new(pattern) =~ line
                print path, file, " ", line_number, ": ", line
            end
rescue
	print "EXCEPTION CAUGHT: skipping a line…\n"
end
			line_number += 1
        end
    }
end


def subdirectories
    subdirs = Dir.entries('.')
    subdirs.delete_if { |d|
        !File.directory?(d) || File.symlink?(d)
    }
    subdirs -= ['.', '..']
end

def recursive_grep(path, pattern, basenames)
    files = Dir.glob(basenames)
    files.each { |file|
        grep_a_file(path, file, pattern)
    }
    subdirs = subdirectories
#p subdirs
    if subdirs.empty? # no subdirectory
		return
	else    
        subdirs.each { |subdir|
#p subdir
            Dir.chdir(subdir)
            subpath = path + subdir + '/'
            recursive_grep(subpath, pattern, basenames)
            Dir.chdir("..")
        }
    end
end


def usage
    print "******** rgrep.rb V0.1.0 ********"
	print "USAGE: rgrep.rb 'pattern' 'filename' ['filename' … ]\n"
	print "Be careful to enclose pattern and each filename in single-quotes, so that shell won't glob them\n"
    print "Note that rgrep.rb digs in the Current Directory only.\n"
end


if ARGV.empty?
    usage
else
    pattern = ARGV[0]
#p pattern
    ARGV.shift
    if ARGV.empty?
        usage
    else
        basenames = Array.new
        dirnames = Array.new

        ARGV.each_with_index { |path, i|
            basenames[i] = File.basename(path)
            dirnames[i] = File.dirname(path)
        }

        basenames.sort!.uniq!
        basenames -= ['.', '..']
=begin
basenames.each { |basename|
    p basename
}
=end
        dirnames.sort!.uniq!
        dirnames -= ['.', '..']
        dirs = dirnames.join(', ')
        unless dirnames.empty?
            print "Sorry, directory specifiers: #{dirs} are discarded.\n"
            print "rgrep.rb digs in the Current Directory only.\n"
        end
        recursive_grep("./", pattern, basenames)
    end # if
end # if
