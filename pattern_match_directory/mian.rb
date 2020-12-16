require 'optparse'
require 'fileutils'

def main
  target = nil
  pattern = nil
  output = nil
  OptionParser.new do |opts|
    opts.on('-t targert_directory', '--target', 'target directory') do |v|
      return 'hoge' unless v

      target = v
    end

    opts.on('-p pattern', '--pattern', 'pattern') do |v|
      return 'hoge' unless v

      pattern = v
    end

    opts.on('-o output', '--output', 'output') do |v|
      return 'hoge' unless v

      output = v
    end
  end.parse!

  pattern ||= '*'
  pattern_match_directory(target, pattern, output)
end

def pattern_match_directory(target, pattern, output)
  # ディレクトリの存在確認
  return 'ng' unless Dir.exist?(target)

  # カレントディレクトリを移動
  i = 0
  FileUtils.cd(target) do
    targert_dirs = []
    Dir.glob("./#{pattern}") do |d|
      targert_dirs << d

      i += 1
    end
    puts targert_dirs
    FileUtils.mkdir_p(output)
    FileUtils.mv(targert_dirs, output, {:noop => true, :verbose => true})
  end
  puts i
end


main if $PROGRAM_NAME == __FILE__
