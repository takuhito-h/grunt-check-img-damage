"use strict";

module.exports = function (grunt) {

    grunt.registerMultiTask("check_img_damage", "Check Images Damage", function(){
        var done = this.async();
        var options = this.options();

        grunt.util.spawn({
            cmd: "ruby",
            args: ["./node_modules/grunt-check-img-damage/check_img_damage.rb", options.globPath]
        }, function(error, result, code){

            // 終了コードをチェック。ログを出力。
            switch(code){
                case 0:
                    grunt.log.ok("success");
                    break;
                case 1:
                    grunt.log.writeln(result.stdout);
                    grunt.log.errorlns("caution!! ファイルが破損しています。");
                    break;
                case 2:
                    grunt.log.writeln(result.stdout);
                    grunt.log.errorlns("caution!! 拡張子が間違っています。");
                    break;
                case 3:
                    grunt.log.writeln(result.stdout);
                    grunt.log.errorlns("caution!! ファイルが破損しています。");
                    grunt.log.errorlns("caution!! 拡張子が間違っています。");
                    break;
            }

            done();
        });
    });
};