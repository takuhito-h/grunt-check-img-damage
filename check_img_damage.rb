# 画像が破損していないかチェックする
# result : [ filetype, result ]
#   checkmessaga = string
#   filename     = string
#   filetype   ::= ( :gif, :jpg, :png, :unknown )
#   result     ::= ( :damaged, :clean )
def check_file(filename)
  result = [[], filename, :unknown, :clean]

  File.open(filename, "rb") do |f|

    # ファイルを読み込む
    begin
      header = f.read(8)
      f.seek(-12, IO::SEEK_END)
      footer = f.read(12)
    rescue
      result[0].push("ファイルが破損しています")
      return result
    end

    # ファイル破損チェック
    if header[0, 2].unpack("H*") == [ "ffd8" ]
      unless footer[-2, 2].unpack("H*") == [ "ffd9" ] then
        result[3] = :damaged
      end
      result[2] = ".jpg"
    elsif header[0, 3].unpack("A*") == [ "GIF" ]
      unless footer[-1, 1].unpack("H*") == [ "3b" ] then
        result[0].push("ファイルが破損しています")
        result[3] = :damaged
      end
      result[2] = ".gif"
    elsif header[0, 8].unpack("H*") == [ "89504e470d0a1a0a" ]
      unless footer[-12, 12].unpack("H*") == [ "0000000049454e44ae426082" ]
        result[0].push("ファイルが破損しています")
        result[3] = :damaged
      end
      result[2] = ".png"
    end

    # 拡張子の齟齬チェック
    if File.extname(filename) != result[2]
      result[0].push("拡張子が間違っています")
      if(result[3] == :damaged)
        result[3] = :ext_error_damaged
      else
        result[3] = :ext_error
      end
    end

  end

  result
end

# globで指定してディレクトリをチェックさせる
def check_dir_glob(glob_dir, put_error_only_flag)
  exit_code = 0
  vol_damage_file = 0
  vol_ext_error_file = 0

  Dir::glob(glob_dir).each do |file|
    check_result_array = check_file(file)

    # エラーが起こったファイル数をカウント
    case check_result_array[3]
    when :damaged then
      vol_damage_file += 1
    when :ext_error then
      vol_ext_error_file += 1
    when :ext_error_damaged then
      vol_damage_file += 1
      vol_ext_error_file += 1
    end      

    # エラーフラグがtrueの場合はエラーがある場合のみ出力
    if(put_error_only_flag)
      if(check_result_array[3] != :clean)
        p check_result_array
      end
    else
      p check_result_array
    end

  end

  # ファイルの破損、拡張子の齟齬があるかでexit_codeを変更
  if(vol_damage_file > 0)
    if(vol_ext_error_file > 0)
      exit_code = 3
    else
      exit_code = 1
    end
  else
    if(vol_ext_error_file > 0)
      exit_code = 2
    else
      exit_code = 0
    end
  end

  exit exit_code
end

# run
check_dir_glob(ARGV[0], true)