
$(function(){
    $(".content form").find("input:visible").eq(0).focus();
    $(".icon_search").click(function(e){
        e.preventDefault();
        $(this).parents(".search-bar").toggleClass("hover").find(".form input:visible").focus();

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

    },function(){
        $(this).removeClass("hover");
    })
});