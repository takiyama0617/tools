# frozen_string_literal: true

require 'optparse'
require 'fileutils'

def main
  options = {}
  OptionParser.new do |opts|
    opts.on('-t targert_directory', '--target', '処理対象のディレクトリパスを指定') do |v|
      options[:target] = v
    end
  end.parse!

  unless options.size == 1
    warn 'コマンドライン引数が不足してます。'
    exit 1
  end

  numbering(options[:target])
end

def numbering(dir)
  unless Dir.exist?(dir)
    warn '[-t]引数で指定したディレクトリが存在しません。'
    exit 1
  end

  cnt = 1
  FileUtils.cd(dir) do
    dirs = Dir.glob('*/').sort
    dirs.each do |d|
      File.rename(d, "#{cnt}_#{d}")
      cnt += 1
    end
  end
  print_dirs(dir)
end

def print_dirs(dir)
  FileUtils.cd(dir) do
    dirs = Dir.glob('*/').sort_by do |v|
      i = v.split('_')[0]
      i.to_i
    end
    puts dirs
  end
end

main if $PROGRAM_NAME == __FILE__
