$(function(){
    function isMobile(){
        var sUserAgent = navigator.userAgent.toLowerCase();
        var bIsIpad = sUserAgent.match(/ipad/i) == "ipad";
        var bIsIphoneOs = sUserAgent.match(/iphone os/i) == "iphone os";
        var bIsMidp = sUserAgent.match(/midp/i) == "midp";
        var bIsUc7 = sUserAgent.match(/rv:1.2.3.4/i) == "rv:1.2.3.4";
        var bIsUc = sUserAgent.match(/ucweb/i) == "ucweb";
        var bIsAndroid = sUserAgent.match(/android/i) == "android";
        var bIsCE = sUserAgent.match(/windows ce/i) == "windows ce";
        var bIsWM = sUserAgent.match(/windows mobile/i) == "windows mobile";
        return bIsIpad || bIsIphoneOs || bIsMidp || bIsUc7 || bIsUc || bIsAndroid || bIsCE || bIsWM;
    }

    $(".flash-removable").on("click",function(){
        $(this).slideUp(300,function(){
            $(this).remove();
        });
    });

    /*form focus*/
    $(".content form").find("input:visible").eq(0).focus();
    $(".icon-search").click(function(e){
        e.stopPropagation();
        e.preventDefault();
        $(this).parents(".search-bar").toggleClass("hover").find(".form input:visible").focus();

    });
    $(".content").on("click",function(){
        $(".search-bar").removeClass("hover");
    }).on("scroll",function(){
        $(".search-bar").removeClass("hover");
    });
    /*menu*/
    $(".menu-link").click(function(){
        $(".nav-left").toggle();
    });
    $(".nav-left>li>a").on("click",function(e){
        var $subMenu = $(this).next("ul");
        if($subMenu){
            e.stopPropagation();
            $(this).parents("li").toggleClass("active").siblings().removeClass("active").find("ul").hide();
            $subMenu.toggle();
        }
    });
    $(document).on("click",function(e){
        var _con = $(".header");
        if(!_con.is(e.target) && _con.has(e.target).length === 0){
            $(".nav-left>li").removeClass("active").find("ul").hide();
            if(isMobile()){
                $(".nav-left").hide();
                $(".search-bar").removeClass("hover");
            }
        }
    });

    $(".book-list li").each(function(){
        if(($(this).index()+1)%3 == 0 && window.outerWidth > 400){
            $(this).addClass("side");
        }
    }).hover(function(){
        $(this).addClass("hover");
        var detail = $(this).find(".detail-span");
        var H = $(window).height();
        var pos = $(this).offset();
        var mh = detail.innerHeight();
        if(H < pos.top+mh){
            detail.css("top",-mh+"px");
        }

    },function(){
        $(this).removeClass("hover");
    });

    if(isMobile()){
        $(".book-list li").unbind("mouseenter").unbind("mouseleave").on("click",function(){
            $(this).toggleClass("hover").siblings().removeClass("hover");
            $("body").scrollTop($(this).offset().top-33)
        });
        $(".book-list li>a").on("click",function(e){
            e.preventDefault();
        })
    }

    $(".them-list>a,.them-list li").on("click",function(e){
        if($(this)[0].tagName == "LI"){
            var theme = $(this)[0].className;
            //$(this).parents("li.them-list").find("a").removeAttr("class").addClass(them);
            $(".reading-page-md").removeClass("theme-6 theme-5 theme-4 theme-3 theme-2 theme-1").addClass(theme);
        }
        $(this).parents("li.them-list").toggleClass("active");
    });

    $(".back-top").on("click",function(e){
        e.preventDefault();
        $("body,html").animate({scrollTop: 0}, "200");
    })

});