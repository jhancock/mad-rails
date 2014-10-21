$(function(){
    $(".tips_remove").delay(2000).hide(300,function(){$(this).remove();});
    $("body").bind('DOMNodeInserted',function(e) {
        $(".tips_remove").delay(2000).hide(300,function(){$(this).remove();});
    });
    $(".content form").find("input:visible").eq(0).focus();
    $(".icon_search").click(function(e){
        e.stopPropagation();
        e.preventDefault();
        $(this).parents(".search-bar").toggleClass("hover").find(".form input:visible").focus();

    });
    $(".content").on("click",function(){
        $(".search-bar").removeClass("hover");
    }).on("scroll",function(){
        $(".search-bar").removeClass("hover");
    });

    $(".menu-link").click(function(){
        if($(this).next(".menu-link-m").length > 0){
            $(".menu-link-m").toggle();
        }else{
            $(".nav").toggle();
        }
    });
    $(".show_category a").click(function(){
        $(this).toggleClass("hover");
        var category = $(this).next("ul");
        category.toggle();
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
    if(navigator.platform.indexOf('Win32')==-1 || window.outerWidth < 400){
        $(".book-list li").unbind("mouseenter").unbind("mouseleave").on("click",function(){
            $(this).toggleClass("hover").siblings().removeClass("hover");
            $("body").scrollTop($(this).offset().top-33)
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