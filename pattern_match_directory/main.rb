require 'optparse'
require 'fileutils'

Version = "1.0.0"

def main
  options = {}
  OptionParser.new do |opts|
    opts.on('-t targert_directory', '--target', '処理対象のディレクトリパスを指定') do |v|
      options[:target] = v
    end

    opts.on('-p pattern', '--pattern', '抽出するディレクトリ名の正規表現を指定') do |v|
      options[:pattern] = v
    end

    opts.on('-o output', '--output', '正規表現にマッチしたディレクトリの移動先') do |v|
      options[:output] = v
    end
  end.parse!

  unless options.size == 3
    STDERR.puts "コマンドライン引数が不足してます。"
    exit 1
  end

  pattern_match_directory(target, pattern, output)
end

def pattern_match_directory(target, pattern, output)
  # ディレクトリの存在確認
  unless Dir.exist?(target)
    STDERR.puts "[-t]引数で指定したディレクトリが存在しません。"
    exit 1
  end

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
  puts "処理対象: #{i}フォルダ"
  puts "move失敗: #{error_dirs}"
end

main if $PROGRAM_NAME == __FILE__
