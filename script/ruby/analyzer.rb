#!/usr/bin/env ruby
#
# Analyze the binaries produced by script/build.sh. For maximum portability, we want to minimize:
# * Binary size
# * Dynamically linked libraries
# * On Linux, versioned GLIBC symbols

require 'optparse'
require 'filesize'
require 'colorize'
require 'os'

require_relative './biglists'

DynamicLib = Struct.new(:path, :ok)

class Analyzer
  def initialize binary
    @binary = binary
    @ok = nil
  end

  def report
    r = "== #{@binary} ==\n".bold
    r << "Filesize: #{self.filesize}\n"
    r << "Dynamic libraries:\n"
    self.dynamic_libs.each do |lib|
      if lib.ok
        r << "  #{lib.path}".green << " ok\n".bold.light_green
      else
        @ok = false
        r << "  #{lib.path}".light_red << " bad\n".bold.light_red
      end
    end
    @ok = true if @ok.nil?
    r
  end

  def ok?
    self.report if @ok.nil?
    @ok
  end

  def filesize
    fs = Filesize.from(File.size(@binary).to_s + " B")
    "#{fs.pretty} (#{fs.to_s})"
  end

  def dynamic_libs
    []
  end

  def highest_glibc_symbols
    []
  end
end

class MacOSAnalyzer < Analyzer
  def dynamic_libs
    `otool -X -L #{@binary}`
      .chomp
      .split(/\n/)
      .map do |line|
        lib = line[/^\s+(\S+)/, 1]
        DynamicLib.new(lib, MACOS_SYSTEM_LIBS.include?(lib))
      end
  end
end

def create_analyzer path
  case
  when OS.mac? ; MacOSAnalyzer.new(path)
  else
    raise RuntimeError.new("Unable to analyze binaries on platform:\n#{OS.report}")
  end
end

binaries = []
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} -b FILE [-b FILE ...]"
  opts.separator ""
  opts.separator "Command line flags:"

  opts.on("-b", "--binary FILE", "A binary to analyze") do |binary|
    binaries << binary
  end
end
opts.parse!

if binaries.empty?
  $stderr.puts "You must specify at least one binary with -b."
  $stderr.puts opts
  exit 1
end

all_ok = true
total_size = 0
binaries.each do |binary|
  total_size += File.size(binary)

  a = create_analyzer binary
  puts a.report

  all_ok &&= a.ok?
end
puts "== Summary ==".bold

total = Filesize.from("#{total_size} B")
puts "Total size: #{total.pretty} (#{total.to_s})"

exit 1 unless all_ok
