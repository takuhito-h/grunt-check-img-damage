"use strict";

module.exports = function (grunt) {

    grunt.registerMultiTask("check_img_damage", "Check Images Damage", function(){
        var done = this.async();
        var options = this.options();

        grunt.util.spawn({
            cmd: "ruby",
            args: ["./node_modules/grunt-check-img-damage/check_img_damage.rb", options.globPath]
        }, function(error, result, code){

            if(code === 0){
                grunt.log.ok("success");
            }else{
                grunt.log.writeln(result.stdout);
                grunt.log.errorlns("error!!");
            }

            done();
        });
    });
};