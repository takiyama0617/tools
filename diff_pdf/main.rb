require 'optparse'

Version = '1.0.0'

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

  puts options
end

def diff_pdf(options)

end


def run(options)

end

def load_yaml
  
end

main if $PROGRAM_NAME == __FILE__