require 'optparse'
require 'yaml'
require 'open3'
require 'fileutils'

Version = '1.0.0'
@setting = nil

def main
  options = {}
  OptionParser.new do |opts|
    opts.on('-t targert_directory', '--target', '処理対象のディレクトリパスを指定') do |v|
      options[:target] = v
    end

    opts.on('-b pattern', '--before-pattern', '比較対象１のPDFファイルを正規表現で指定') do |v|
      options[:b_file_pattern] = v
    end

    opts.on('-a pattern', '--after-pattern', '比較対象２のPDFファイルを正規表現で指定') do |v|
      options[:a_file_pattern] = v
    end

    opts.on('-s', '--skip-identical', 'Diffがあるページのみ出力する') do |v|
      options[:skip] = v
    end

    opts.on('-m', '--mark-differences', '右側に相違箇所にしるしを付ける') do |v|
      options[:mark] = v
    end
  end.parse!

  @setting = load_yaml
  puts @setting
  puts options

  diff_pdf(options)
end

def diff_pdf(options)
  # ディレクトリの存在確認
  unless Dir.exist?(options[:target])
    STDERR.puts '[-t]引数で指定したディレクトリが存在しません。'
    exit 1
  end

  FileUtils.cd(options[:target]) do
    before_files = []
    after_files = []

    Dir.glob("./*/#{options[:b_file_pattern]}*.pdf") do |f|
      before_files << File.expand_path(f)
    end

    Dir.glob("./*/#{options[:a_file_pattern]}*.pdf") do |f|
      after_files << File.expand_path(f)
    end

    puts before_files
    puts '================'
    puts after_files

    args = []
    args << '-s' if options[:skip]
    args << '-m' if options[:mark]

    run(format(@setting['diff-pdf'], { ROOT_DIR: __dir__ }), args)
  end
end

def run(exe, args)
  args.flatten!
  puts exe
  o, e, ret = Open3.capture3(exe, *args)
end

def load_yaml
  YAML.load_file(File.join(__dir__, 'setting.yml'))
end

main if $PROGRAM_NAME == __FILE__
