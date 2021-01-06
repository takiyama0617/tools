# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'open3'
require 'fileutils'
require 'pp'

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
  diff_pdf(options)
end

def diff_pdf(options)
  # ディレクトリの存在確認
  unless Dir.exist?(options[:target])
    warn '[-t]引数で指定したディレクトリが存在しません。'
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

    # PDFの比較
    differences = []
    diff_file_list(before_files, after_files).each do |obj|
      args = []
      args << '-s' if options[:skip]
      args << '-m' if options[:mark]
      args << "--output-diff=#{obj.parents_dir}/diff.pdf"
      # args << '--view'
      args << obj.before.to_s
      args << obj.after.to_s
      _, _, ret = run(format(@setting['diff-pdf'], { ROOT_DIR: __dir__ }), args)

      differences << obj.parents_dir unless ret.success?
    end

    puts "全体：#{before_files.size}, 差分ありファイル数: #{differences.size}"
    puts '差分ありファイルがあるディレクトリは、以下'
    pp differences
  end
end

def run(exe, args)
  args.flatten!
  o, e, ret = Open3.capture3(exe, *args)
end

def load_yaml
  YAML.load_file(File.join(__dir__, 'setting.yml'))
end

def diff_file_list(before_files, after_files)
  file_list = []
  before_files.zip(after_files) do |b, a|
    obj = Struct.new(:before, :after, :parents_dir)
    file_list << obj.new(b, a, File.dirname(b))
  end
  file_list
end

main if $PROGRAM_NAME == __FILE__
