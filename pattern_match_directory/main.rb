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
  error_dirs = []
  FileUtils.cd(target) do
    targert_dirs = []
    Dir.glob("./#{pattern}") do |d|
      targert_dirs << d

      i += 1
    end

    # 移動先のディレクトリを作成
    FileUtils.mkdir_p(output)

    # 移動
    targert_dirs.each do |dir|
      begin
        FileUtils.mv(dir, output, { verbose: true })
      rescue => ex
        error_dirs << dir
      end
    end
  end
  puts "合計: #{i}フォルダ"
  puts "copy失敗: #{error_dirs}"
end

main if $PROGRAM_NAME == __FILE__
