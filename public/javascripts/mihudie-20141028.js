var Cookies = {};
/**
 * set Cookies
 */
Cookies.set = function(name, value){
    var argv = arguments;
    var argc = arguments.length;
    var days = (argc > 2) ? argv[2] : null;
    var expires   =new Date();
    expires.setTime(expires.getTime() + days*24*60*60*1000);
    var path = (argc > 3) ? argv[3] : '/';
    var domain = (argc > 4) ? argv[4] : null;
    var secure = (argc > 5) ? argv[5] : false;
    document.cookie = name + "=" + escape (value) +
        ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) +
        ((path == null) ? "" : ("; path=" + path)) +
        ((domain == null) ? "" : ("; domain=" + domain)) +
        ((secure == true) ? "; secure" : "");
};
/**
 * read Cookies
 */
Cookies.get = function(name){
    var arg = name + "=";
    var alen = arg.length;
    var clen = document.cookie.length;
    var i = 0;
    var j = 0;
    while(i < clen){
        j = i + alen;
        if (document.cookie.substring(i, j) == arg)
            return Cookies.getCookieVal(j);
        i = document.cookie.indexOf(" ", i) + 1;
        if(i == 0)
            break;
    }
    return null;
};
/**
 * clear Cookies
 */
Cookies.clear = function(name) {
    if(Cookies.get(name)){
        var expdate = new Date();
        expdate.setTime(expdate.getTime() - (86400 * 1000 * 1));
        Cookies.set(name, "", expdate);
    }
};

Cookies.getCookieVal = function(offset){
    var endstr = document.cookie.indexOf(";", offset);
    if(endstr == -1){
        endstr = document.cookie.length;
    }
    return unescape(document.cookie.substring(offset, endstr));
};

//Cookies.set("config", JSON.stringify(config),"30"); //days
//Cookies.clear("config");

$(function(){
    var defaultTheme = Cookies.get("mhd_theme");
    if(defaultTheme){
        $(".reading-page-md").addClass(defaultTheme);
        var $themeSelected = $(".book-theme").find("."+defaultTheme);
        $themeSelected.addClass("theme-selected").siblings().removeClass("theme-selected");
    }
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

    var body_h = window.innerHeight,body_w = window.innerWidth;

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
    $(".nav-left>li").hover(function(e){
        var $subMenu = $(this).find("ul");
        if($subMenu.length){
            e.stopPropagation();
            $(this).addClass("active").siblings().removeClass("active").find("ul").hide();
            $subMenu.show();
        }
    },function(){
        $(this).removeClass("active").find("ul").hide();
    });
//    $(".nav-left>li>a").on("click",function(e){
//        var $subMenu = $(this).next("ul");
//        if($subMenu){
//            e.stopPropagation();
//            $(this).parents("li").toggleClass("active").siblings().removeClass("active").find("ul").hide();
//            $subMenu.toggle();
//        }
//    });
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

    var $book_list = $(".details"),$book_list_item = $book_list.find("li");
    var show_action = $book_list.data("action");

    $book_list_item.find(".detail-span-action").on("click",function(e){
        e.stopPropagation();
    });
    if(show_action=="click"){
        $book_list_item.unbind("mouseenter").unbind("mouseleave").on("click",function(e){
            e.stopPropagation();
            var H = $("body").height();
            var pos = $(this).offset();
            $(this).toggleClass("hover");
            $(this).siblings().removeClass("hover");
            var detail = $(this).find(".detail-span");
            var mh = detail.innerHeight();
            if(H < pos.top+mh){
                detail.css("top",-mh+"px");
            }
            if(pos.left+detail[0].offsetWidth > body_w-20){
                detail.css({
                    left:"inherit",
                    right:"0"
                });
            }
        })
    }else{
        $book_list_item.unbind("click").hover(function(e){
            e.stopPropagation();
            $(this).addClass("hover");
            var detail = $(this).find(".detail-span");
            var H = $(window).height();
            var pos = $(this).offset();
            var mh = detail.innerHeight();
            if(H < pos.top+mh){
                detail.css("top",-mh+"px");
            }
            if(pos.left+detail[0].offsetWidth > body_w-20){
                detail.css({
                    left:"inherit",
                    right:"0"
                });
            }

        },function(){
            $(this).removeClass("hover");
        });
    }
    if(isMobile()){
        $book_list_item.unbind("mouseenter").unbind("mouseleave").unbind("click").on("click",function(){
            $(this).toggleClass("hover").siblings().removeClass("hover");
            $("body").scrollTop($(this).offset().top-33)
        });
        $(".details>li>a").on("click",function(e){
            e.preventDefault();
        });
    }


    $(".theme-list>a,.theme-list li").on("click",function(e){
        if($(this)[0].tagName == "LI"){
            var theme = $(this)[0].className;
            var reg = /\s*theme-\w*-\w*\s*/g;
            var $reading = $(".reading-page-md");
            var classes = $reading.attr("class").replace(reg,"");
            $reading.attr("class",classes);
            $reading.addClass(theme);
            Cookies.set("mhd_theme", theme,"30");
        }
        $(this).parents("li.theme-list").toggleClass("active");
    });
    $(".book-theme .theme-item").on("click",function(e){
        var reg = /theme-\w*-\w*/g;
        var theme = $(this).attr("class").match(reg);
        $(this).addClass("theme-selected").siblings().removeClass("theme-selected");
        Cookies.set("mhd_theme", theme,"30");
    });

    $(".back-top").on("click",function(e){
        e.preventDefault();
        $("body,html").animate({scrollTop: 0}, "200");
    });


    $(".content").css("min-height",body_h-61-71+"px");

});