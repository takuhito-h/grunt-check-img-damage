"use strict";

module.exports = function (grunt) {

    grunt.registerMultiTask("check_img_damage", "Check Images Damage", function(){
        var done = this.async();
        var options = this.options();

        var green_code = "\u001b[32m";
        var red_code = "\u001b[31m";
        var reset_code = "\u001b[0m";

        grunt.util.spawn({
            cmd: "ruby",
            args: ["./node_modules/grunt-check-img-damage/check_img_damage.rb", options.globPath]
        }, function(error, result, code){

            // 終了コードをチェック。ログを出力。
            switch(code){
                case 0:
                    grunt.log.ok(green_code + "success!" + reset_code);
                    break;
                case 1:
                    grunt.log.writeln(result.stdout);
                    grunt.log.errorlns(red_code + "caution!! ファイルが破損しています。" + reset_code);
                    break;
                case 2:
                    grunt.log.writeln(result.stdout);
                    grunt.log.errorlns(red_code + "caution!! 拡張子が間違っています。" + reset_code);
                    break;
                case 3:
                    grunt.log.writeln(result.stdout);
                    grunt.log.errorlns(red_code + "caution!! ファイルが破損しています。" + reset_code);
                    grunt.log.errorlns(red_code + "caution!! 拡張子が間違っています。" + reset_code);
                    break;
            }

            done();
        });
    });
};