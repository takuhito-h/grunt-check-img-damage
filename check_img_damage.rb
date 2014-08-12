# 画像が破損していないかチェックする
# result : [ filetype, result ]
#   filetype ::= ( :gif, :jpg, :png, :unknown )
#   result   ::= ( :damaged, :clean )
def check_file(filename)
  result = ["○", filename, :unknown]  
  File.open(filename, "rb") do |f|
    begin
      header = f.read(8)
      f.seek(-12, IO::SEEK_END)
      footer = f.read(12)
    rescue
      result[0] = "×"
      return result
    end

    if header[0,2].unpack("H*") == [ "ffd8" ]
      result[0] = "×" unless footer[-2,2].unpack("H*") == [ "ffd9" ]
      result[2] = ".jpg"
    elsif header[0,3].unpack("A*") == [ "GIF" ]
      result[0] = "×" unless footer[-1,1].unpack("H*") == [ "3b" ]
      result[2] = ".gif"
    elsif header[0,8].unpack("H*") == [ "89504e470d0a1a0a" ]
      result[0] = "×" unless footer[-12,12].unpack("H*") == [ "0000000049454e44ae426082" ]
      result[2] = ".png"
    end

  end
  result
end

# globで指定してディレクトリをチェックさせる
def check_dir_glob(glob_dir, put_error_only_flag)
  exit_code = 0

  Dir::glob(glob_dir).each do |file|
    result = check_file(file)

    # ファイル破損チェック
    # if(put_error_only_flag)
    #   if result[0] == "×"
    #     result[3] = "ファイルが破損しています"
    #     p result
    #     exit_code = 1
    #   end
    # else
    #   p result
    # end

    # 拡張子が合ってない画像を出力
    if(File.extname(file) != result[2])
      result[3] = "拡張子が間違っています"
      p result
      exit_code = 1
    end

  end

  exit exit_code
end

# run
check_dir_glob(ARGV[0], true)