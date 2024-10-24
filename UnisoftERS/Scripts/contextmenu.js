
function onAddSiteMenuShow(target, pos) {
    //alert('contextmenu.js: onAddSiteMenuShow');
    //var s = target;alert(0);
    //alert(s.data('AntPos'));
}

function onAddSiteMenuItemSelect(menuitem, target) {
    //alert('contextmenu.js: onAddSiteMenuItemSelect');
    //var s = target;
    target.data('AntPos', menuitem.text());
    target.data('PositionAssigned', true);
    //SetSiteStyle(paper.getById($(target)[0].raphaelid));
    SetSiteStyle(target);
    //alert(siteDragged);

    if (siteDragged) {
        siteDragged = false;
        UpdateSite(target);
    }
    else {
        InsertSite(target);
    }
}

function onDiagramContextMenuShow(target, pos) {
    // DiagramMenuShow($('#DiagramDiv'), target);
}

function onDiagramContextMenuItemSelect(menuitem, target) {
    openDiagnosesWindow();
}

function onProtocolSiteContextMenuShow(target, pos) {
    SiteMenuShow($('#ProtocolSiteClickMenu'), target);
}

function onSiteContextMenuShow(target, pos) {
    SiteMenuShow($('#SiteClickMenu'), target);
}

function onSiteContextMenuItemSelect(menuitem, target) {
    SiteMenuItemSelect($('#SiteClickMenu'), menuitem, target);
}

function onEbusSiteClickMenuShow(target, pos) {
    SiteMenuShow($('#EbusSiteClickMenu'), target);
}

function onEbusSiteContextMenuItemSelect(menuitem, target) {
    SiteMenuItemSelect($('#EbusSiteClickMenu'), menuitem, target);
}

function onLymphNodeSiteContextMenuItemSelect(menuitem, target) {
    SiteMenuItemSelect($('#LymphNodeSiteClickMenu'), menuitem, target);
}

function onPhotoContextMenuShow(target, pos) {

}

function onPhotoContextMenuItemSelect(menuitem, target) {
    if (menuitem[0].text.indexOf("Detach") >= 0) {
        if (confirm('Are you sure you want to detach this photo from the site? You can attach it back from the Attach Photo screen.')) {
            DetachPhoto(target);
        }
    }
    else if (menuitem[0].text.indexOf("Move") >= 0) {
        openMovePhotoWindow(target);
    }
}

function onVideoContextMenuShow(target, pos) {

}

function onVideoContextMenuItemSelect(menuitem, target) {
    if (menuitem[0].text.indexOf("Detach") >= 0) {
        if (confirm('Are you sure you want to detach this video from the site? You can attach it back from the Attach Photo screen.')) {
            DetachVideo(target);
        }
    }
    else if (menuitem[0].text.indexOf("Move") >= 0) {
        openMoveVideoWindow(target);
    }
}

function SiteMenuShow(menu, target) {
    var s = target;
    //var antpos = s.data('AntPos');
    var antpos = (s.data('AntPos') == 'BothOrEither') ? "Both / Either" : s.data('AntPos');
    var is3D = s.data('is3D');

    if (!is3D) {
        menu.find('a[radio="AntPos"]').hide();
        menu.find('.separator').eq(1).hide();
    }
    else {
        menu.find('a[radio="AntPos"]').show();
        menu.find('.separator').eq(1).show();

        TickAntPosItem(menu, antpos);
    }
}

function SiteMenuItemSelect(menu, menuitem, target) {

    if (menuitem[0].getAttribute("radio") == "AntPos") {
        target.data('AntPos', menuitem.text());
        target.data('PositionAssigned', true);
        TickAntPosItem(menu, menuitem.text());
        SetSiteStyle(target);
        UpdateSite(target);
    }
    else if (menuitem[0].text == "Remove Site") {
        //if (confirm('Are you sure you want to remove this site and all associated data if any?')) {
        //    DeleteSite(target);
        //}
        DeleteSite(target);
    }
    //else if (menuitem[0].text == "Attach Photos") {
    //    openPhotosWindow();
    //}
    //lymph node
    else if (target.data("SiteId") == -1) {

        InsertLymphNodeSite(target);
    }
    else {
        var siteId = target.data("SiteId");

        var region;
        if (resectionColonId != "") {
            region = "Anastomosis";
        }
        else {
            region = target.data("Region");
        }

        OpenSiteDetails(region, siteId, menuitem[0].text, '', target.data("AreaNo"));
    }
}

function TickAntPosItem(menu, antpos) {
    menu
        .find('a[radio="AntPos"]').removeAttr('checked')
        .parent().removeClass('checked')
        .end()
        .end()
        .find('li > a:contains("' + antpos + '")').attr('checked', 'checked')
        .parent().addClass('checked')
        .end()
        .end();
}

Raphael.el.is = function (type) { return this.type == ('' + type).toLowerCase(); };
Raphael.el.x = function () { return this.is('circle') ? this.attr('cx') : this.attr('x'); };
Raphael.el.y = function () { return this.is('circle') ? this.attr('cy') : this.attr('y'); };
Raphael.el.o = function () { this.ox = this.x(); this.oy = this.y(); return this; };

(function ($) {
    $.extend($.fn,
        {

            AddSiteMenu: function (options) {
                if (!$(site.node).data('is3D')) {
                    $(site.node).data('AntPos', 'Both / Either');
                    SetSiteStyle($(site.node));
                    InsertSite($(site.node));
                    return;
                }

                // Defaults

                //// get bounding rect of the paper
                //var bnds = event.target.getBoundingClientRect();

                //// adjust mouse x/y
                //var mx = event.clientX - bnds.left;
                //var my = event.clientY - bnds.top;

                //if (!isWithinRegions(mx, my)) {
                //    //return;
                //    //$(".contextMenu").hide();
                //    alert(1);
                //}

                var defaults =
                {
                    fadeIn: 150,
                    fadeOut: 75
                },
                    o = $.extend(true, defaults, options || {}),
                    d = document;

                //alert(sitecoords.length);

                //alert(o.mouseY);
                // Loop each context menu
                $(this).each(function () {

                    var el = $(this),
                        offset = el.offset(),
                        $m = $('#' + o.menu);

                    // Add contextMenu class
                    $m.addClass('contextMenu');

                    // Simulate a true right click
                    //$(this).mousedown(function (e) {

                    // e.stopPropagation(); 
                    //$(this).mouseup(function (e) {
                    // e.stopPropagation(); 
                    var target = $(this);
                    //var raphelem = this;
                    //alert(target.attr('cx'));
                    //alert(target.attr('cy'));
                    //alert(target);
                    //alert(target.attr("fill"));
                    //alert(allsitecoords[0]);
                    // Removes any previously attached event handlers
                    $(this).unbind('mouseup');

                    //if (e.button == 0) {
                    // Hide context menus that may be showing
                    $(".contextMenu").hide();
                    // Get this context menu

                    if (el.hasClass('disabled')) return false;

                    // show context menu on mouse coordinates or keep it within visible window area
                    //var x = Math.min(e.pageX, $(document).width() - $m.width() - 5),
                    //    y = Math.min(e.pageY, $(document).height() - $m.height() - 5);

                    //var x = Math.min(e.pageX, $(document).width() - $m.width() - 5),
                    //                y = Math.min(e.pageY, $(document).height() - $m.height() - 5);

                    ////alert(allsitecoords.length);
                    //var posx = e.pageX - $(document).scrollLeft() - $('#DiagramDiv').offset().left;
                    //var posy = e.pageY - $(document).scrollTop() - $('#DiagramDiv').offset().top;
                    //alert(posx);
                    //alert(posy);

                    //alert(target.attr('cx'));
                    //alert(target.attr('cy'));
                    //var x = Number(target.attr('cx')) + Number($(document).scrollLeft()) + Number($('#DiagramDiv').offset().left);
                    //var y = Number(target.attr('cy')) + Number($(document).scrollTop()) + Number($('#DiagramDiv').offset().top);
                    var x = Number(target.attr('cx')) + Number($('#DiagramDiv').offset().left);
                    var y = Number(target.attr('cy')) + Number($('#DiagramDiv').offset().top);


                    //$("#CoordLabel").text(x + "," + y + " A " + target.attr('cx') + "," + target.attr('cy') + " B " + $(document).scrollLeft() + "," + $(document).scrollTop() + " C " + $('#DiagramDiv').offset().left + "," + $('#DiagramDiv').offset().top);
                    //var newx = target.attr('cx');
                    //var newy = target.attr('cy');

                    //alert(newx); alert(newy);
                    ////if ((!isWithinRegions(posx, posy)) || !(addsite || markarea)) {
                    //if (!isWithinRegions(posx, posy) || !addsite) {
                    //    //alert(1);
                    //    //$(".contextMenu").hide();
                    //    return null;
                    //}

                    //alert(o.fadeIn);
                    // Show the menu
                    $(document).unbind('click');
                    $m
                        .css({ top: y, left: x })
                        .fadeIn(o.fadeIn)
                        .find('A')
                        .mouseover(function () {
                            $m.find('LI.hover').removeClass('hover');
                            $(this).parent().addClass('hover');
                        })
                        .mouseleave(function () {
                            $m.find('LI.hover').removeClass('hover');
                        });

                    //if (o.onShow) o.onShow(this, { x: x - offset.left, y: y - offset.top, docX: x, docY: y });
                    if (o.onShow) o.onShow($(target), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });
                    // Keyboard
                    //$(document).keypress(function (e) {
                    //    //alert(e.keyCode);
                    //    var $hover = $m.find('li.hover'),
                    //        $first = $m.find('li:first'),
                    //        $last = $m.find('li:last');

                    //    switch (e.keyCode) {
                    //        case 38: // up
                    //            if ($hover.size() == 0) {
                    //                $last.addClass('hover');
                    //            } else {
                    //                $hover.removeClass('hover').prevAll('LI:not(.disabled)').eq(0).addClass('hover');
                    //                if ($hover.size() == 0) $last.addClass('hover');
                    //            }
                    //            break;
                    //        case 40: // down
                    //            if ($hover.size() == 0) {
                    //                $first.addClass('hover');
                    //            } else {
                    //                $hover.removeClass('hover').nextAll('LI:not(.disabled)').eq(0).addClass('hover');
                    //                if ($hover.size() == 0) $first.addClass('hover');
                    //            }
                    //            break;
                    //        case 13: // enter
                    //            $m.find('LI.hover A').trigger('click');
                    //            break;
                    //        case 27: // esc
                    //            $(document).trigger('click');
                    //            break;
                    //    }
                    //});

                    // When items are selected
                    $m.find('A').unbind('click');
                    $m.find('LI:not(.disabled) A').click(function () {
                        var checked = $(this).attr('checked');

                        //alert(checked);
                        //switch ($(this).attr('type')) // custom attribute
                        //{
                        //    case 'radio':
                        //        $(this).parent().parent().find('.checked').removeClass('checked').end().find('a[checked="checked"]').removeAttr('checked');
                        //        // break; // continue...
                        //    case 'checkbox':
                        //        if ($(this).attr('checked') || checked) {
                        //            $(this).removeAttr('checked');
                        //            $(this).parent().removeClass('checked');
                        //        }
                        //        else {
                        //            $(this).attr('checked', 'checked');
                        //            $(this).parent().addClass('checked');
                        //        }

                        //        //if ($(this).attr('hidemenu'))
                        //        {
                        //            $(".contextMenu").hide();
                        //        }
                        //        break;
                        //    default:
                        //        $(document).unbind('click').unbind('keypress');
                        //        $(".contextMenu").hide();
                        //        break;
                        //}
                        $(document).unbind('click').unbind('keypress');
                        $(".contextMenu").hide();
                        // Callback
                        //if (o.onSelect) {
                        //    o.onSelect($(this), $(target), $(this).attr('href'), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });
                        //}
                        if (o.onSelect) {
                            //alert($(this).text() + ' --- ' +  $(target));
                            o.onSelect($(this), $(target));
                        }
                        return false;
                    });

                    // Hide bindings
                    setTimeout(function () { // Delay for Mozilla
                        $(document).click(function () {
                            var t = $(target);
                            //alert(t.data('AntPos'));
                            if (t.data('AntPos') == undefined) {
                                alert("Please specify whether the site is Anterior or Posterior");
                            }
                            else {
                                $(document).unbind('click').unbind('keypress');
                                $m.fadeOut(o.fadeOut);
                                return false;
                            }
                        });
                    }, 100);
                    //}
                    //    });
                    //});

                    // Disable text selection
                    if ($.browser) { // latest version of jQuery no longer supports $.browser()
                        if ($.browser.mozilla) {
                            $m.each(function () { $(this).css({ 'MozUserSelect': 'none' }); });
                        } else if ($.browser.msie) {
                            $m.each(function () { $(this).bind('selectstart.disableTextSelect', function () { return false; }); });
                        } else {
                            $m.each(function () { $(this).bind('mousedown.disableTextSelect', function () { return false; }); });
                        }
                    }
                    // Disable browser context menu (requires both selectors to work in IE/Safari + FF/Chrome)
                    el.add($('UL.contextMenu')).bind('contextmenu', function () { return false; });

                });
                return $(this);
            },
            // Destroy context menu(s)
            destroyContextMenu: function () {
                // Destroy specified context menus
                $(this).each(function () {
                    // Disable action
                    $(this).unbind('mousedown').unbind('mouseup');
                });
                return ($(this));
            }
        });
})(jQuery);


(function ($) {
    $.extend($.fn,
        {
            SiteContextMenu: function (options) {
                // Defaults

                //// get bounding rect of the paper
                //var bnds = event.target.getBoundingClientRect();

                //// adjust mouse x/y
                //var mx = event.clientX - bnds.left;
                //var my = event.clientY - bnds.top;

                //if (!isWithinRegions(mx, my)) {
                //    //return;
                //    //$(".contextMenu").hide();
                //    alert(1);
                //}

                var defaults =
                {
                    fadeIn: 150,
                    fadeOut: 75
                },
                    o = $.extend(true, defaults, options || {}),
                    d = document;

                //alert(sitecoords.length);

                //alert(o.mouseY);
                // Loop each context menu
                $(this).each(function () {
                    var el = $(this),
                        offset = el.offset(),
                        $m = $('#' + o.menu);   //If EBUS then EbusSiteClickMenu

                    // Add contextMenu class
                    $m.addClass('contextMenu');

                    //alert('Simulate a true right click');
                    // Simulate a true right click
                    $(this).mousedown(function (e) {

                        // e.stopPropagation(); 
                        $(this).mouseup(function (e) {
                            // e.stopPropagation(); 
                            var target = $(this);

                            // Removes any previously attached event handlers
                            $(this).unbind('mouseup');

                            if (e.button == 2) {
                                // Hide context menus that may be showing
                                $(".contextMenu").hide();
                                // Get this context menu
                                //alert(21);
                                if (el.hasClass('disabled')) return false;
                                //alert(22);
                                // show context menu on mouse coordinates or keep it within visible window area
                                var x = Math.min(e.pageX, $(document).width() - $m.width() - 5),
                                    y = Math.min(e.pageY, $(document).height() - $m.height() - 5);

                                //alert(allsitecoords.length);
                                //var posx = e.pageX - $(document).scrollLeft() - $('#DiagramDiv').offset().left;
                                //var posy = e.pageY - $(document).scrollTop() - $('#DiagramDiv').offset().top;

                                ////if ((!isWithinRegions(posx, posy)) || !(addsite || markarea)) {
                                //if (!isWithinRegions(posx, posy) || !addsite) {
                                //    //alert(1);
                                //    //$(".contextMenu").hide();
                                //    return null;
                                //}

                                //alert(o.fadeIn);
                                // Show the menu
                                $(document).unbind('click');
                                $m
                                    .css({ top: y, left: x })
                                    .fadeIn(o.fadeIn)
                                    .find('A')
                                    .mouseover(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                        $(this).parent().addClass('hover');
                                    })
                                    .mouseleave(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                    });

                                //if (o.onShow) o.onShow(this, { x: x - offset.left, y: y - offset.top, docX: x, docY: y });
                                if (o.onShow) o.onShow($(target), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });

                                //// Keyboard
                                //$(document).keypress(function (e) {
                                //    //alert(e.keyCode);
                                //    var $hover = $m.find('li.hover'),
                                //        $first = $m.find('li:first'),
                                //        $last = $m.find('li:last');

                                //    switch (e.keyCode) {
                                //        case 38: // up
                                //            if ($hover.size() == 0) {
                                //                $last.addClass('hover');
                                //            } else {
                                //                $hover.removeClass('hover').prevAll('LI:not(.disabled)').eq(0).addClass('hover');
                                //                if ($hover.size() == 0) $last.addClass('hover');
                                //            }
                                //            break;
                                //        case 40: // down
                                //            if ($hover.size() == 0) {
                                //                $first.addClass('hover');
                                //            } else {
                                //                $hover.removeClass('hover').nextAll('LI:not(.disabled)').eq(0).addClass('hover');
                                //                if ($hover.size() == 0) $first.addClass('hover');
                                //            }
                                //            break;
                                //        case 13: // enter
                                //            $m.find('LI.hover A').trigger('click');
                                //            break;
                                //        case 27: // esc
                                //            $(document).trigger('click');
                                //            break;
                                //    }
                                //});

                                //COMMENTED AS SUBMENU NOT REQUIRED
                                //var $m2;

                                ////$m.find('a[submenu]').mouseenter(function () {
                                //$m.find('LI:not(.disabled) A').mouseenter(function () {

                                //    // Close any sub-menu that's showing
                                //    if ($m2) {
                                //        $m2.fadeOut(o.fadeOut);
                                //        $m2 = null;
                                //    }

                                //    // Show sub-menu
                                //    var mainmenuname = $(this).attr("submenu");
                                //    if (mainmenuname != undefined) {
                                //        $m2 = $('#' + mainmenuname);

                                //        $m2.addClass('contextMenu');
                                //        $m2
                                //           .css({ top: y, left: x + $m.width() - 3 })
                                //           .fadeIn(o.fadeIn)
                                //           .find('A')
                                //               .mouseover(function () {
                                //                   $m2.find('LI.hover').removeClass('hover');
                                //                   $(this).parent().addClass('hover');
                                //               })
                                //               .mouseleave(function () {
                                //                   $m2.find('LI.hover').removeClass('hover');
                                //               });
                                //    }
                                //});

                                //// Close the sub-menu only when it is not being hovered over
                                //$m.find('a[submenu]').mouseleave(function () {
                                //    if ($m2 && !$m2.is(':hover'))
                                //    {
                                //        $m2.fadeOut(o.fadeOut);
                                //    }

                                //});
                                //END OF COMMENTED SECTION FOR AVOIDING SUBMENUS

                                // When items are selected
                                $m.find('A').unbind('click');
                                $m.find('LI:not(.disabled) A').click(function () {
                                    var checked = $(this).attr('checked');

                                    // $m2 = $('#AbnormalitiesSubMenu');
                                    // $m2.addClass('contextMenu');
                                    // $m2
                                    //.css({ top: y+20, left: x+20 })
                                    //.fadeIn(o.fadeIn)
                                    //.find('A')
                                    //    .mouseover(function () {
                                    //        $m2.find('LI.hover').removeClass('hover');
                                    //        $(this).parent().addClass('hover');
                                    //    })
                                    //    .mouseout(function () {
                                    //        $m2.find('LI.hover').removeClass('hover');
                                    //    });

                                    //switch ($(this).attr('type')) // custom attribute
                                    //{
                                    //    case 'radio':
                                    //        $(this).parent().parent().find('.checked').removeClass('checked').end().find('a[checked="checked"]').removeAttr('checked');
                                    //        // break; // continue...
                                    //    case 'checkbox':
                                    //        if ($(this).attr('checked') || checked) {
                                    //            $(this).removeAttr('checked');
                                    //            $(this).parent().removeClass('checked');
                                    //        }
                                    //        else {
                                    //            $(this).attr('checked', 'checked');
                                    //            $(this).parent().addClass('checked');
                                    //        }

                                    //        //if ($(this).attr('hidemenu'))
                                    //        {
                                    //            $(".contextMenu").hide();
                                    //        }
                                    //        break;
                                    //    default:
                                    //        $(document).unbind('click').unbind('keypress');
                                    //        $(".contextMenu").hide();
                                    //        break;
                                    //}
                                    $(document).unbind('click').unbind('keypress');
                                    $(".contextMenu").hide();
                                    // Callback
                                    if (o.onSelect) {
                                        o.onSelect($(this), $(target));
                                    }
                                    return false;
                                });

                                // Hide bindings
                                setTimeout(function () { // Delay for Mozilla
                                    $(document).click(function () {
                                        $(document).unbind('click').unbind('keypress');
                                        //$m.fadeOut(o.fadeOut);
                                        $(".contextMenu").fadeOut(o.fadeOut);
                                        return false;
                                    });
                                }, 0);
                            }
                        });
                    });

                    // Disable text selection
                    if ($.browser) { // latest version of jQuery no longer supports $.browser()
                        if ($.browser.mozilla) {
                            $m.each(function () { $(this).css({ 'MozUserSelect': 'none' }); });
                        } else if ($.browser.msie) {
                            $m.each(function () { $(this).bind('selectstart.disableTextSelect', function () { return false; }); });
                        } else {
                            $m.each(function () { $(this).bind('mousedown.disableTextSelect', function () { return false; }); });
                        }
                    }
                    // Disable browser context menu (requires both selectors to work in IE/Safari + FF/Chrome)
                    el.add($('UL.contextMenu')).bind('contextmenu', function () { return false; });

                });
                return $(this);
            },
            // Destroy context menu(s)
            destroyContextMenu: function () {
                // Destroy specified context menus
                $(this).each(function () {
                    // Disable action
                    $(this).unbind('mousedown').unbind('mouseup');
                });
                return ($(this));
            }
        });
})(jQuery);

(function ($) {
    $.extend($.fn,
        {
            PhotoContextMenu: function (options) {

                var defaults =
                {
                    fadeIn: 150,
                    fadeOut: 75
                },
                    o = $.extend(true, defaults, options || {}),
                    d = document;

                // Loop each context menu
                $(this).each(function () {

                    var el = $(this),
                        offset = el.offset(),
                        $m = $('#' + o.menu);

                    // Add contextMenu class
                    $m.addClass('contextMenu');

                    // Simulate a true right click
                    $(this).mousedown(function (e) {

                        // e.stopPropagation(); 
                        $(this).mouseup(function (e) {
                            // e.stopPropagation(); 
                            var target = $(this);

                            // Removes any previously attached event handlers
                            $(this).unbind('mouseup');

                            if (e.button == 2) {
                                // Hide context menus that may be showing
                                $(".contextMenu").hide();
                                // Get this context menu

                                if (el.hasClass('disabled')) return false;

                                // show context menu on mouse coordinates or keep it within visible window area
                                var x = Math.min(e.pageX, $(document).width() - $m.width() - 5),
                                    y = Math.min(e.pageY, $(document).height() - $m.height() - 5);

                                // Show the menu
                                $(document).unbind('click');
                                $m
                                    .css({ top: y, left: x })
                                    .fadeIn(o.fadeIn)
                                    .find('A')
                                    .mouseover(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                        $(this).parent().addClass('hover');
                                    })
                                    .mouseleave(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                    });

                                if (o.onShow) o.onShow($(target), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });

                                // When items are selected
                                $m.find('A').unbind('click');
                                $m.find('LI:not(.disabled) A').click(function () {
                                    var checked = $(this).attr('checked');

                                    $(document).unbind('click').unbind('keypress');
                                    $(".contextMenu").hide();
                                    // Callback
                                    if (o.onSelect) {
                                        o.onSelect($(this), $(target));
                                    }
                                    return false;
                                });

                                // Hide bindings
                                setTimeout(function () { // Delay for Mozilla
                                    $(document).click(function () {
                                        $(document).unbind('click').unbind('keypress');
                                        //$m.fadeOut(o.fadeOut);
                                        $(".contextMenu").fadeOut(o.fadeOut);
                                        return false;
                                    });
                                }, 0);
                            }
                        });
                    });

                    // Disable text selection
                    if ($.browser) { // latest version of jQuery no longer supports $.browser()
                        if ($.browser.mozilla) {
                            $m.each(function () { $(this).css({ 'MozUserSelect': 'none' }); });
                        } else if ($.browser.msie) {
                            $m.each(function () { $(this).bind('selectstart.disableTextSelect', function () { return false; }); });
                        } else {
                            $m.each(function () { $(this).bind('mousedown.disableTextSelect', function () { return false; }); });
                        }
                    }
                    // Disable browser context menu (requires both selectors to work in IE/Safari + FF/Chrome)
                    el.add($('UL.contextMenu')).bind('contextmenu', function () { return false; });
                });
                return $(this);
            },
            // Destroy context menu(s)
            destroyContextMenu: function () {
                // Destroy specified context menus
                $(this).each(function () {
                    // Disable action
                    $(this).unbind('mousedown').unbind('mouseup');
                });
                return ($(this));
            }
        });
})(jQuery);


(function ($) {
    $.extend($.fn,
        {
            VideoContextMenu: function (options) {

                var defaults =
                {
                    fadeIn: 150,
                    fadeOut: 75
                },
                    o = $.extend(true, defaults, options || {}),
                    d = document;

                // Loop each context menu
                $(this).each(function () {

                    var el = $(this),
                        offset = el.offset(),
                        $m = $('#' + o.menu);

                    // Add contextMenu class
                    $m.addClass('contextMenu');

                    // Simulate a true right click
                    $(this).mousedown(function (e) {

                        // e.stopPropagation(); 
                        $(this).mouseup(function (e) {
                            // e.stopPropagation(); 
                            var target = $(this);

                            // Removes any previously attached event handlers
                            $(this).unbind('mouseup');

                            if (e.button == 2) {
                                // Hide context menus that may be showing
                                $(".contextMenu").hide();
                                // Get this context menu

                                if (el.hasClass('disabled')) return false;

                                // show context menu on mouse coordinates or keep it within visible window area
                                var x = Math.min(e.pageX, $(document).width() - $m.width() - 5),
                                    y = Math.min(e.pageY, $(document).height() - $m.height() - 5);

                                // Show the menu
                                $(document).unbind('click');
                                $m
                                    .css({ top: y, left: x })
                                    .fadeIn(o.fadeIn)
                                    .find('A')
                                    .mouseover(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                        $(this).parent().addClass('hover');
                                    })
                                    .mouseleave(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                    });

                                if (o.onShow) o.onShow($(target), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });

                                // When items are selected
                                $m.find('A').unbind('click');
                                $m.find('LI:not(.disabled) A').click(function () {
                                    var checked = $(this).attr('checked');

                                    $(document).unbind('click').unbind('keypress');
                                    $(".contextMenu").hide();
                                    // Callback
                                    if (o.onSelect) {
                                        o.onSelect($(this), $(target));
                                    }
                                    return false;
                                });

                                // Hide bindings
                                setTimeout(function () { // Delay for Mozilla
                                    $(document).click(function () {
                                        $(document).unbind('click').unbind('keypress');
                                        //$m.fadeOut(o.fadeOut);
                                        $(".contextMenu").fadeOut(o.fadeOut);
                                        return false;
                                    });
                                }, 0);
                            }
                        });
                    });

                    // Disable text selection
                    if ($.browser) { // latest version of jQuery no longer supports $.browser()
                        if ($.browser.mozilla) {
                            $m.each(function () { $(this).css({ 'MozUserSelect': 'none' }); });
                        } else if ($.browser.msie) {
                            $m.each(function () { $(this).bind('selectstart.disableTextSelect', function () { return false; }); });
                        } else {
                            $m.each(function () { $(this).bind('mousedown.disableTextSelect', function () { return false; }); });
                        }
                    }
                    // Disable browser context menu (requires both selectors to work in IE/Safari + FF/Chrome)
                    el.add($('UL.contextMenu')).bind('contextmenu', function () { return false; });
                });
                return $(this);
            },
            // Destroy context menu(s)
            destroyContextMenu: function () {
                // Destroy specified context menus
                $(this).each(function () {
                    // Disable action
                    $(this).unbind('mousedown').unbind('mouseup');
                });
                return ($(this));
            }
        });
})(jQuery);


(function ($) {
    $.extend($.fn,
        {

            DragSiteMenu: function (options) {


                var defaults =
                {
                    fadeIn: 150,
                    fadeOut: 75
                },
                    o = $.extend(true, defaults, options || {}),
                    d = document;

                $(this).each(function () {

                    var el = $(this),
                        offset = el.offset(),
                        $m = $('#' + o.menu);

                    // Add contextMenu class
                    $m.addClass('contextMenu');



                    // Simulate a true right click
                    //$(this).mousedown(function (e) {

                    // e.stopPropagation(); 
                    //$(this).mouseup(function (e) {
                    // e.stopPropagation(); 
                    var target = $(this);

                    // Removes any previously attached event handlers
                    $(this).unbind('mouseup');

                    //if (e.button == 0) {
                    // Hide context menus that may be showing
                    $(".contextMenu").hide();
                    // Get this context menu

                    if (el.hasClass('disabled')) return false;

                    var x = Number(target.attr('cx')) + Number($('#DiagramDiv').offset().left);
                    var y = Number(target.attr('cy')) + Number($('#DiagramDiv').offset().top);

                    // Show the menu
                    $(document).unbind('click');
                    $m
                        .css({ top: y, left: x })
                        .fadeIn(o.fadeIn)
                        .find('A')
                        .mouseover(function () {
                            $m.find('LI.hover').removeClass('hover');
                            $(this).parent().addClass('hover');
                        })
                        .mouseleave(function () {
                            $m.find('LI.hover').removeClass('hover');
                        });

                    //if (o.onShow) o.onShow(this, { x: x - offset.left, y: y - offset.top, docX: x, docY: y });
                    if (o.onShow) o.onShow($(target), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });

                    // When items are selected
                    $m.find('A').unbind('click');
                    $m.find('LI:not(.disabled) A').click(function () {
                        var checked = $(this).attr('checked');

                        $(document).unbind('click').unbind('keypress');
                        $(".contextMenu").hide();

                        if (o.onSelect) {
                            //alert($(this).text() + ' --- ' +  $(target));
                            o.onSelect($(this), $(target));
                        }
                        return false;
                    });



                    // Hide bindings
                    setTimeout(function () { // Delay for Mozilla
                        $(document).click(function () {
                            var t = $(target);
                            //alert(t.data('AntPos'));
                            if (t.data('AntPos') == 'undefined') {
                                alert("Please specify whether the site is Anterior or Posterior");
                            }
                            else {
                                $(document).unbind('click').unbind('keypress');
                                $m.fadeOut(o.fadeOut);
                                return false;
                            }
                        });
                    }, 100);

                    // Disable text selection
                    if ($.browser) { // latest version of jQuery no longer supports $.browser()
                        if ($.browser.mozilla) {
                            $m.each(function () { $(this).css({ 'MozUserSelect': 'none' }); });
                        } else if ($.browser.msie) {
                            $m.each(function () { $(this).bind('selectstart.disableTextSelect', function () { return false; }); });
                        } else {
                            $m.each(function () { $(this).bind('mousedown.disableTextSelect', function () { return false; }); });
                        }
                    }
                    // Disable browser context menu (requires both selectors to work in IE/Safari + FF/Chrome)
                    el.add($('UL.contextMenu')).bind('contextmenu', function () { return false; });

                });
                return $(this);
            },
            // Destroy context menu(s)
            destroyContextMenu: function () {
                // Destroy specified context menus
                $(this).each(function () {
                    // Disable action
                    $(this).unbind('mousedown').unbind('mouseup');
                });
                return ($(this));
            }
        });
})(jQuery);


(function ($) {
    $.extend($.fn,
        {
            DiagramContextMenu: function (options) {

                // Defaults
                var defaults =
                {
                    fadeIn: 50,
                    fadeOut: 25
                },
                    o = $.extend(true, defaults, options || {}),
                    d = document;

                // Loop each context menu
                $(this).each(function () {
                    var el = $(this),
                        offset = el.offset(),
                        $m = $('#' + o.menu);

                    // Add contextMenu class
                    $m.addClass('contextMenu');

                    // Simulate a true right click
                    $(this).mousedown(function (e) {

                        $(this).mouseup(function (e) {

                            var target = $(this);

                            // Removes any previously attached event handlers
                            $(this).unbind('mouseup');
                            if (e.button == 2) {
                                // Hide context menus that may be showing
                                $(".contextMenu").hide();
                                // Get this context menu

                                if (el.hasClass('disabled')) return false;

                                // show context menu on mouse coordinates or keep it within visible window area
                                var x = Math.min(e.pageX, $(document).width() - $m.width() - 5),
                                    y = Math.min(e.pageY, $(document).height() - $m.height() - 5);

                                // Show the menu
                                $(document).unbind('click');
                                $m
                                    .css({ top: y, left: x })
                                    .fadeIn(o.fadeIn)
                                    .find('A')
                                    .mouseover(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                        $(this).parent().addClass('hover');
                                    })
                                    .mouseleave(function () {
                                        $m.find('LI.hover').removeClass('hover');
                                    });

                                if (o.onShow) o.onShow($(target), { x: x - offset.left, y: y - offset.top, docX: x, docY: y });

                                // When items are selected
                                $m.find('A').unbind('click');
                                $m.find('LI:not(.disabled) A').click(function () {
                                    var checked = $(this).attr('checked');

                                    $(document).unbind('click').unbind('keypress');
                                    $(".contextMenu").hide();
                                    // Callback
                                    if (o.onSelect) {
                                        o.onSelect($(this), $(target));
                                    }
                                    return false;
                                });

                                // Hide bindings
                                setTimeout(function () { // Delay for Mozilla
                                    $(document).click(function () {
                                        $(document).unbind('click').unbind('keypress');
                                        //$m.fadeOut(o.fadeOut);
                                        $(".contextMenu").fadeOut(o.fadeOut);
                                        return false;
                                    });
                                }, 0);
                            }
                        });
                    });

                    // Disable text selection
                    if ($.browser) { // latest version of jQuery no longer supports $.browser()
                        if ($.browser.mozilla) {
                            $m.each(function () { $(this).css({ 'MozUserSelect': 'none' }); });
                        } else if ($.browser.msie) {
                            $m.each(function () { $(this).bind('selectstart.disableTextSelect', function () { return false; }); });
                        } else {
                            $m.each(function () { $(this).bind('mousedown.disableTextSelect', function () { return false; }); });
                        }
                    }
                    // Disable browser context menu (requires both selectors to work in IE/Safari + FF/Chrome)
                    el.add($('UL.contextMenu')).bind('contextmenu', function () { return false; });

                });
                return $(this);
            },
            // Destroy context menu(s)
            destroyContextMenu: function () {
                // Destroy specified context menus
                $(this).each(function () {
                    // Disable action
                    $(this).unbind('mousedown').unbind('mouseup');
                });
                return ($(this));
            }
        });
})(jQuery);