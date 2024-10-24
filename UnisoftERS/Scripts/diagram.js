//var siteRadius = 5;
var addsite = false;
var markarea = false;
var isAreaFirstSite = false; //Identify first site for the area
//var sitecoords = [];
//var allsitecoords = [];
var site;

var paper;

//var line1;
//var line2;
//var lines = [];
//var pathArrays  = [];
var mouseButton = 3;
//var pathArray1;
//var pathArray2;
var id = 0;

var independentSites = [];
var linkedSites = []; //use this only for the area thats being freshly drawn
var continuousLine;
//var jsonsite;
//var currentSiteIndex;
//var currentSiteIndex2;
var mpx, mpy;

var areaId;
var is3D;
//var areaClosed;
var activeSite;
var activeSiteAnim = Raphael.animation({ r: 8 }, 1000, "elastic");
var siteDragged = false;
//var areaPath;

var regions = [];
var regionsExist = false;

var diagram;
var arNo = 0;
var areas = [];
//var diagramHeight = 0;
//var diagramWidth = 0;
//var selectedProcType = 0;
var ebus;

var docURL = document.URL;
var popup;
var disableTitlePopup = false;
var rawImgURL;
var resectedColonSet = new Set();

function LoadBasics() {
    if (paper != null) {
        paper.remove();
        addsite = false;
        markarea = false;
        //sitecoords = [];
        //allsitecoords = [];
        linkedSites = [];
        regionsExist = false;
        regions = [];
        //line1 = null;
        //pathArray1 = null;
        ebus = false;
    }

    resectedColonSet = new Set(resectionColonId.split(',').filter(item => item !== '').map(Number));

    siteRadius = (siteRadius / 500) * ((Number(diagramHeight) + Number(diagramWidth)) / 2);

    paper = new Raphael(document.getElementById('DiagramDiv'), diagramWidth, diagramHeight);

    rawImgURL = imageUrl;
    diagram = paper.image(imageUrl, 0, 0, diagramWidth, diagramHeight)
        .mousemove(function (event) {
            //var posx = event.clientX - ($(document).scrollLeft() + $('#DiagramDiv').offset().left);
            //var posy = event.clientY - ($(document).scrollTop() + $('#DiagramDiv').offset().top);
            var posx = event.pageX - ($('#DiagramDiv').offset().left);
            var posy = event.pageY - ($('#DiagramDiv').offset().top);
            $("#CoordLabel").text(posx + "," + posy);
            //$("#CoordLabel").text(posx + "," + posy + " A " + event.clientX + "," + event.clientY + " B " + event.pageX + "," + event.pageY + " C " + $('#DiagramDiv').offset().left + "," + $('#DiagramDiv').offset().top);
            var reg = GetRegion(posx, posy);

            if (reg != "") {
                reg = reg.split(";")[1];
            }

            if (resectionColonId != "") {
                var resectedRegions = getSelectedRegions(resectedColonSet)
                if ($.inArray(reg, resectedRegions) > -1) {
                    reg = "Anastomosis";
                }

            }

            $("#" + positionLabelClientId).text(reg);
            if (addsite == true || markarea == true) {
                if (reg != "") {
                    $('#DiagramDiv').css('cursor', 'crosshair');

                    //commented out the elasticity feature temporarily
                    //if (markarea == true && continuousLine != undefined) {
                    //    var mypatharr = continuousLine.attr("path");
                    //    mypatharr[0][1] = posx;
                    //    mypatharr[0][2] = posy;
                    //    continuousLine.attr({ path: mypatharr });
                    //}
                }
                else {
                    $('#DiagramDiv').css('cursor', 'default');
                }
            }
        })

        //right-click for Diagnoses
        /*        diagram.mousedown(function (event) {
                    mouseButton = event.which;
                    if (mouseButton !== 3) {return;}
                    SetDiagramContextMenu();
                })
        */
        .click(function () {
            if (addsite === true || markarea === true) {
                $('#DiagramDiv').css('cursor', 'default');

                // Get bounding rect of the paper
                //var bnds = event.target.getBoundingClientRect();
                // Adjust mouse x/y
                //var mx = event.clientX - 8;
                //var my = event.clientY - 130;

                //// Get x and y of the diagram div
                //var dx = Number(Number($(document).scrollLeft()) + Number($('#DiagramDiv').offset().left));
                //var dy = Number(Number($(document).scrollTop()) + Number($('#DiagramDiv').offset().top));
                //// adjust mouse x/y
                //var a = event.clientX - dx;
                //var b = event.clientY - dy;
                //alert(a + "," + b);

                //var mx = event.clientX - ($(document).scrollLeft() + $('#DiagramDiv').offset().left);
                //var my = event.clientY - ($(document).scrollTop() + $('#DiagramDiv').offset().top);

                //-- event.pageX & pageY : Returning wrong values for IE version prior to 11

                //var mx = event.pageX - ($('#DiagramDiv').offset().left);
                //var my = event.pageY - ($('#DiagramDiv').offset().top);

                var mx = (window.pageXOffset + window.event.clientX) - ($('#DiagramDiv').offset().left);
                var my = (window.pageYOffset + window.event.clientY) - ($('#DiagramDiv').offset().top);

                //alert(mx + "," + my);

                //alert(event.clientX + "," + event.clientY);
                //alert(event.pageX + "," + event.pageY);

                if (!isWithinRegions(mx, my)) {
                    return;
                }

                // divide x/y by the bounding w/h to get location %s and apply factor by actual paper w/h
                //var fx = mx / bnds.width * rect.attrs.width
                //var fy = my / bnds.height * rect.attrs.height

                // cleanup output
                //fx = Number(fx).toPrecision(3);
                //fy = Number(fy).toPrecision(3);

                //var reg = GetRegion(mx, my);
                var regionDetails = GetRegion(mx, my);
                var regId = regionDetails.split(";")[0];
                var reg = regionDetails.split(";")[1];

                //$(site.node).data('Region', reg);
                //$(site.node).data('Coordinates', mx + "," + my);

                var partOfArea = false;
                if (markarea === true) {

                    //--Area not allowed outside of the main anatomical diagram for EUS (OGD [6] & HPB [7])
                    if ((['6', '7'].indexOf(selectedProcType) >= 0) && (['Mediastinal', 'Site'].indexOf(reg) >= 0)) {
                        alert('Area not allowed outside of the main anatomical diagram.')
                        return;
                    }

                    if (linkedSites.length >= 1) {
                        partOfArea = true;
                    }
                }

                site = PlantSite(mx, my, null, partOfArea);

                if (is3D) {
                    $(site.node).data('is3D', true);
                } else {
                    $(site.node).data('is3D', false);
                }

                $(site.node).data('PositionAssigned', false);

                $(site.node).data('RegionId', regId);
                $(site.node).data('Region', reg);
                $(site.node).data('Coordinates', mx + "," + my);

                //allsitecoords.push(mx + "," + my);

                //determinePosition(my);

                //if (site == -1) {       //EBUS AddEbusSiteClickMenu

                //}
                if (addsite === true) {
                    $(site.node).data('AreaNo', 0);

                    independentSites.push(site);

                    $([site.node]).AddSiteMenu({
                        menu: 'AddSiteMenu',
                        onShow: onAddSiteMenuShow,
                        onSelect: onAddSiteMenuItemSelect
                    });

                    //$([site.node]).AddSiteMenu({
                    //    menu: 'AddSiteMenu'
                    //});

                    addsite = false;
                }
                else if (markarea === true) {
                    $(site.node).data('AntPos', 'Both / Either');
                    $(site.node).data('AreaNo', arNo);
                    $(site.node).data('PartOfArea', partOfArea);

                    PopulateLinkedSites(site);
                    if (linkedSites.length > 1) {
                        $(site.node).data('PartOfArea', true);
                    }

                    SetSiteStyle($(site.node));
                    InsertSite($(site.node));
                    DrawLine(mx, my, site);
                    var areaClosed = false;
                    if (linkedSites.length >= 3) {
                        areaClosed = isCloseEnough();
                    }

                    //commented out the elasticity feature temporarily
                    //if (!areaClosed) {
                    //    DrawContinuousLine(mx, my);
                    //}
                    //else {
                    //    continuousLine.remove();
                    //    continuousLine = null;
                    //}
                }
            }
        })

    loadResection();

    if (selectedProcType === "1" || selectedProcType === "6") {
        LoadProtocolSiteNodes();
    }

    if (selectedProcType === "11") {
        AddLymphNodesForNewEbusProcedure();
    }
};

function PlantSite(x, y, position, partOfArea) {

    id = id + 1;

    var site = paper.circle(x, y, siteRadius)
        .attr({
            fill: "white",
            cursor: "pointer"
        })

        .mousedown(function (event) {
            mouseButton = event.which;
        })

        .click(function () {

            //alert(event.which);
            if (!siteDragged) {
                //alert(0);
                //this.attr({ r:10 })
                //a(this);
                //this.animate({ r: 8 }, 1000).repeat(Infinity);
                //this.animate({ r: 10, fill: '#00f' }, 1000);
                //starSpin();
                //var anim = Raphael.animation({ transform: "r360" }, 2500).repeat(Infinity);
                //site.animate(anim);
                //a();

                $(document).unbind('click');

                if (activeSite) {
                    activeSite.stop();

                    var poa = $(activeSite.node).data('PartOfArea');
                    if (poa != undefined && poa === true) {
                        var att = {
                            fill: "blue",
                            r: siteRadius / 2
                        };
                        activeSite.attr(att);
                    }
                    else {
                        var att = {
                            r: siteRadius
                        };
                        activeSite.attr(att);
                    }
                    activeSite = null;

                    //CloseSlideMenu();
                    //$("#SlideMenuButton").hide();
                }
                activeSite = this;
                SetTreeNode($(activeSite.node).data('SiteId'));
                //this.toFront();
                var anim = Raphael.animation({ r: 8 }, 1000, "elastic");
                this.animate(anim.repeat(Infinity));

                if (!partOfArea) {
                    $("#SlideMenuButton").show();
                }

                // setTimeout in this case is used like thread yielding in this case. 
                // Without this, the animation.stop runs immediately after the animation is set. So no effect on the front end.
                // Use of setTimeout makes sure the current code is executed before the new code gets executed.
                setTimeout(function () {
                    $(document).click(function (evt) {
                        //if (evt.target.id == "SlideMenuButton")
                        //    return;
                        if ($(evt.target).closest('#SlideMenu').length) {
                            return;
                        }
                        if ($(evt.target).closest('#SlideMenuButton').length) {
                            return;
                        }

                        if (activeSite) {
                            activeSite.stop();

                            var poa = $(activeSite.node).data('PartOfArea');
                            if (poa != undefined && poa == true) {
                                var att = {
                                    fill: "blue",
                                    r: siteRadius / 2
                                };
                                activeSite.attr(att);
                            }
                            else {
                                var att = {
                                    r: siteRadius
                                };
                                activeSite.attr(att);
                            }
                            activeSite = null;

                            //CloseSlideMenu();
                            //$("#SlideMenuButton").hide();
                        }
                    });
                }, 0);
            }
        })


        //.drag(progress, start, finish)

        //.hover(function () {
        //    DrawTooltip(this, 1, siteTitle, x, y);
        //},
        //  function () {
        //      DrawTooltip(this, 0);
        //  })

        //.qtip(
        //    {
        //        content: {
        //            text: 'example of SVG support'
        //        },
        //        position: {
        //            target: 'mouse',
        //            adjust: {
        //                mouse: true,
        //                y: +20
        //            }
        //        }
        //    })

        ;

    //$(site.node).click(function (e) { alert("click") });


    //var starSpin = function () {
    //    alert(0);
    //    site.attr({ rotation: 0 }).animate({ rotation: 360 }, 5000, starSpin);
    //}

    //$([site.node]).contextMenu({
    //    menu: 'AddSiteMenu',
    //    onShow: onContextMenuShow,
    //    onSelect: onContextMenuItemSelect
    //});

    //var m = $('#AddSiteMenu');
    //m.addClass('contextMenu');
    //m
    //    .css({ top: event.clientY, left: event.clientX })
    //    .fadeIn(150)
    //    .find('A')
    //        .mouseover(function () {
    //            $m.find('LI.hover').removeClass('hover');
    //            $(this).parent().addClass('hover');
    //        })
    //        .mouseout(function () {
    //            $m.find('LI.hover').removeClass('hover');
    //        });

    //if (o.onShow) o.onShow(this, { x: x - offset.left, y: y - offset.top, docX: x, docY: y });
    //alert(m);

    //var reg = GetRegion(mx, my);

    //$(site.node).data('Coordinates', x + "," + y);

    //if (region != undefined) {
    //    $(site.node).data('RegionId', region.split(";")[0]);
    //    $(site.node).data('Region', region.split(";")[1]);
    //}

    if (position != undefined) {
        $(site.node).data('AntPos', position);
    }

    SetSiteStyle($(site.node));

    //if (!partOfArea) {
    //    $([site.node]).SiteContextMenu({
    //        menu: 'SiteClickMenu',
    //        onShow: onSiteContextMenuShow,
    //        onSelect: onSiteContextMenuItemSelect
    //    });
    //}

    if (!partOfArea) {
        //if (selectedProcType != 11) {
            $([site.node]).SiteContextMenu({
                menu: 'SiteClickMenu',
                onShow: onSiteContextMenuShow,
                onSelect: onSiteContextMenuItemSelect
            });
        //} else {
        //    $([site.node]).SiteContextMenu({
        //        menu: 'EbusSiteClickMenu',
        //        onShow: onEbusSiteClickMenuShow,
        //        onSelect: onEbusSiteContextMenuItemSelect
        //    });
        //};
    }

    return site;
}

function DrawTooltip(object, show) {

    var txt, strxy, strx, stry, x, y;

    txt = $(object).data('SiteTitle');
    strxy = $(object).data('Coordinates');
    //x = $(object).cx.baseVal.value;
    //y = $(object).cy.baseVal.value;
    //x = object[0].cx.baseVal.value;
    //y = object[0].cx.baseVal.value;
    if (txt == undefined) {
        txt = $(object.node).data('SiteTitle');
        strxy = $(object.node).data('Coordinates');
        //x = $(object.node).cx.baseVal.value;
        //y = $(object.node).cy.baseVal.value;
    }

    //x = object.cx.baseVal.value;
    //y = object.cy.baseVal.value;
    //alert(text); alert(x); alert(y);

    strx = strxy.split(",")[0];
    stry = strxy.split(",")[1];
    x = Number(strx);
    y = Number(stry);

    if (show == 0 || disableTitlePopup == true) {
        disableTitlePopup = false;
        if (popup) {
            popup.remove();
            popup_txt.remove();
            transparent_txt.remove();
        }
        $("b:contains('" + txt + "')").removeClass('txtSiteHighlight'); //remove the class that highlights the text for the corresponding site
        return;
    }

    if (txt == undefined || txt == "") { return; }
    txt = "Site " + txt;
    //draw text somewhere to get its dimensions and make it transparent
    transparent_txt = paper.text(100, 100, txt).attr({ fill: "transparent" });

    //get text dimensions to obtain tooltip dimensions
    var txt_box = transparent_txt.getBBox();

    //draw text
    popup_txt = paper.text(x + txt_box.width, y - txt_box.height - 6, txt).attr({ fill: "#484848", font: "18px sans-serif" });

    var bb = popup_txt.getBBox();

    //draw path for tooltip box
    popup = paper.path(
        // 'M'ove to the 'dent' in the bubble
        "M" + (x) + " " + (y - 4) +
        // 'v'ertically draw a line 5 pixels more than the height of the text
        "v" + -(bb.height + 3) +
        // 'h'orizontally draw a line 10 more than the text's width
        "h" + (bb.width + 10) +
        // 'v'ertically draw a line to the bottom of the text
        "v" + bb.height +
        // 'h'orizontally draw a line so we're 5 pixels fro thge left side
        "h" + -(bb.width + 5) +
        // 'Z' closes the figure  "#CADDF5"  "#767676"
        "Z").attr({ fill: "#fffff0", stroke: "#000000", "stroke-width": "0.2" });


    //finally put the text in front
    popup_txt.toFront();
    //Add class to highlight the text for the corresponding site, if found
    $("b:contains('" + txt + ":')").addClass('txtSiteHighlight');

}

function PopulateLinkedSites(site) {
    var linkedsite =
    {
        "id": id,
        //"siteElement": site,
        "siteElement": site,
        //"siteCoord": mx + "," + my,
        //"lines": {
        "line1": null,
        "pathArray1": null,
        "line2": null,
        "pathArray2": null
        //}
    };

    linkedSites.push(linkedsite);
}

function DrawLine(x, y, s) {

    //var line;
    //id = id + 1;
    //alert(id);

    //sitecoords.push(mx + "," + my);
    //sitecoords.push(x + "," + y);

    //if (sitecoords.length > 1 && markarea == true) {
    if (linkedSites.length >= 2) {
        //line = paper.path("M" + sitecoords[sitecoords.length - 2] + " L" + sitecoords[sitecoords.length - 1]);
        var prevSiteCoordinates = $(linkedSites[linkedSites.length - 2].siteElement.node).data("Coordinates");
        var line = paper.path("M" + prevSiteCoordinates + " L" + x + "," + y);

        line.attr({ "stroke": "red" });
        //pathArray = line.attr("path");

        //lines.push({"line":line, "path":pathArray});
        //lines.push(sitecoords.length);
        //lines.push(line);
        //pathArrays.push(pathArray);

        //line1 = line;
        //pathArray1 = pathArray;

        //if (linkedSites != null) {
        //    var prev = linkedSites[id - 2];

        //    var temp =
        //    {
        //        "id": prev["id"],
        //        "siteElement": prev["siteElement"],
        //        //"siteCoord": prev["siteCoord"],
        //        //"lines": {
        //        "line1": prev["line1"],
        //        "pathArray1": prev["pathArray1"],
        //        "line2": lines[lines.length - 1],
        //        "pathArray2": pathArrays[pathArrays.length - 1]
        //        //}
        //    };
        //    linkedSites[id - 2] = temp;
        //}

        linkedSites[linkedSites.length - 2].line2 = line;
        linkedSites[linkedSites.length - 2].pathArray2 = line.attr("path");

        linkedSites[linkedSites.length - 1].line1 = line;
        linkedSites[linkedSites.length - 1].pathArray1 = line.attr("path");

        //if (linkedSites.length >= 3) {
        //    isCloseEnough();
        //}
    }



    //var jsonsite =
    //    {
    //        "id": id,
    //        //"siteElement": site,
    //        "siteElement": s,
    //        //"siteCoord": mx + "," + my,
    //        //"lines": {
    //        "line1": line1,
    //        "pathArray1": pathArray1,
    //        "line2": line2,
    //        "pathArray2": pathArray2
    //        //}
    //    };

    //linkedSites.push(jsonsite);

    //isCloseEnough();
}

function DrawContinuousLine(x, y) {
    if (continuousLine != undefined) {
        continuousLine.remove();
        continuousLine = null;
    }

    continuousLine = paper.path("M" + x + "," + y + " L" + x + "," + y)

        .click(function (event) {

            diagram.trigger('click', diagram);
        });

    continuousLine.attr({ "stroke": "red" });
}

function InitialiseArea() {
    id = 0;
    areaId = 0;
    arNo = arNo + 1;
    linkedSites = [];
    //sitecoords = [];
    //lines = [];
    //pathArrays = [];
    //line1 = null;
    //pathArray1 = null;
}

function LoadExistingPatient() {
    var patientSites = $.parseJSON(existingSites);
    //for (i = 0; i < patientSites.length; i++) {
    //    //var site = paper.circle(patientSites[i]["XCoordinate"], patientSites[i]["YCoordinate"], siteRadius)
    //    //         .attr({
    //    //             cursor: "pointer"
    //    //         })
    //    var site = PlantSite(
    //        patientSites[i]["XCoordinate"],
    //        patientSites[i]["YCoordinate"],
    //        patientSites[i]["Region"],
    //        patientSites[i]["AntPos"])

    //    //$(site.node).data('AntPos', patientSites[i]["AntPos"]);
    //    //SetSiteStyle($(site.node));
    //    //alert(patientSites[i]["SiteId"]);
    //    $(site.node).data('SiteId', patientSites[i]["SiteId"]);
    //    $(site.node).data('AreaNo', patientSites[i]["AreaNo"]);
    //    //alert($(site.node).data('SiteId'));
    //}

    var areaNos = [];
    $(patientSites).each(function (i) {

        if (($.inArray(this.AreaNo, areaNos)) == -1) {
            areaNos.push(this.AreaNo);
        }
    });

    $(areaNos).each(function () {

        //var myid = 0;
        var an = this;
        //var mysitecoords = [];
        if (an != 0) {
            InitialiseArea();
        }

        var mysites = jQuery.grep(patientSites, function (n, i) {
            return (n.AreaNo == an);
        });

        $(mysites).each(function () {

            var partOfArea = false;
            if (this.AreaNo > 0) {
                if (linkedSites.length >= 1) {
                    partOfArea = true;
                }
            }

            var site = PlantSite(this.XCoordinate, this.YCoordinate, this.AntPos, partOfArea);
            
            $(site.node).data('SiteId', this.SiteId);
            $(site.node).data('AreaNo', this.AreaNo);
            $(site.node).data('PartOfArea', partOfArea);
            $(site.node).data('SiteTitle', this.SiteTitle);
            $(site.node).data('is3D', this.In3DRegion);
            $(site.node).data('PositionAssigned', this.PositionSpecified);
            $(site.node).data('RegionId', this.RegionId);
            $(site.node).data('Region', this.Region);
            $(site.node).data('IsLymphNode', this.IsLymphNode);
            $(site.node).data('Coordinates', this.XCoordinate + "," + this.YCoordinate);

            site.hover(function () {
                DrawTooltip(this, 1);
            },
                function () {
                    DrawTooltip(this, 0);
                });



            if (this.AreaNo == 0) {
                independentSites.push(site);
            }
            else {
                PopulateLinkedSites(site);
                if (linkedSites.length > 1) {
                    $(site.node).data('PartOfArea', true);
                }
                SetSiteStyle($(site.node));

                DrawLine(this.XCoordinate, this.YCoordinate, site);
                if (linkedSites.length >= 3) {
                    isCloseEnough();
                }
            }

            //here maybe?
            if (this.IsProtocol == true) {
                //change colour
                //disable right click options other than add photo
                SetProcolSiteStyle($(site.node));
            }

            if ($(site.node).data('IsLymphNode') == true) {
                //change colour

                SetLymphNodeSiteStyle($(site.node));
            }
            else {

            }

        });

        if (an != 0) {
            arNo = an;
            var a = {
                areaNum: arNo,
                areaSites: linkedSites,
                raphId: areaId
            }
            areas.push(a);
        }

        linkedSites = [];


        //var mysites = patientSites.
        //var a = {
        //    areaNum: this,
        //    areaSites: linkedSites,
        //    raphId: 0
        //}
        //areas.push(a)
    });

    //$.each(patientSites, function (i, item) {
    //    $("<option/>")
    //        .attr("value", item.id)
    //        .append(item.name)
    //        .appendTo("optgroup[label='" + item.category + "']");
    //});
}

function AddLymphNodesForNewEbusProcedure() {
    var lymphNodes = $.parseJSON(regionPathsEbusLymphNodes);

    for (i = 0; i < lymphNodes.length; i++) {

        var thisNode = paper.circle(lymphNodes[i]["XCoordinate"], lymphNodes[i]["YCoordinate"], siteRadius)
            .attr({
                fill: "yellow",
                cursor: "auto"
            });

        //Set node so its identified as a lymph node
        $(thisNode.node).data('AreaNo', 0);
        $(thisNode.node).data('AntPos', 'BothOrEither');
        $(thisNode.node).data('IsLymphNode', true);
        $(thisNode.node).data('LymphNodeId', lymphNodes[i]["EBUSLymphNodeId"]);
        $(thisNode.node).data('SiteId', -1);
        $(thisNode.node).data('Region', lymphNodes[i]["Region"]);
        $(thisNode.node).data('RegionId', lymphNodes[i]["RegionId"]);
        $(thisNode.node).data('Coordinates', lymphNodes[i]["Coordinates"]);
        $(thisNode.node).data('AreaNo', lymphNodes[i]["AreaNo"]);
        thisNode.hover(function () { DrawTooltipForlymphNodes(this, 1); }, function () { DrawTooltipForlymphNodes(this, 0); });
        $([thisNode.node]).SiteContextMenu({
            menu: 'EbusSiteClickMenu',
            onShow: onEbusSiteClickMenuShow,
            onSelect: onEbusSiteContextMenuItemSelect
        });
    }
}
function DrawTooltipForlymphNodes(object, show) {

    var txt, strxy, strx, stry, x, y;

    txt = $(object).data('Region');
    strxy = $(object).data('Coordinates');
    //x = $(object).cx.baseVal.value;
    //y = $(object).cy.baseVal.value;
    //x = object[0].cx.baseVal.value;
    //y = object[0].cx.baseVal.value;
    if (txt == undefined) {
        txt = $(object.node).data('Region');
        strxy = $(object.node).data('Coordinates');
        //x = $(object.node).cx.baseVal.value;
        //y = $(object.node).cy.baseVal.value;
    }

    //x = object.cx.baseVal.value;
    //y = object.cy.baseVal.value;
    //alert(text); alert(x); alert(y);

    strx = strxy.split(",")[0];
    stry = strxy.split(",")[1];
    x = Number(strx)- Number(strx)/2;
    y = Number(stry);
    if ((Number(strx) + 100) > diagramWidth) {
        x = x - (Number(strx) - (diagramWidth-115));//Number(strx) + 100 - 350
    }
    if (show == 0 || disableTitlePopup == true) {
        disableTitlePopup = false;
        if (popup) {
            popup.remove();
            popup_txt.remove();
            transparent_txt.remove();
        }
        $("b:contains('" + txt + "')").removeClass('txtSiteHighlight'); //remove the class that highlights the text for the corresponding site
        return;
    }

    if (txt == undefined || txt == "") { return; }
    //txt = "Site " + txt;
    //draw text somewhere to get its dimensions and make it transparent
    transparent_txt = paper.text(100, 100, txt).attr({ fill: "transparent" });

    //get text dimensions to obtain tooltip dimensions
    var txt_box = transparent_txt.getBBox();

    //draw text
    popup_txt = paper.text(x + txt_box.width, y - txt_box.height - 6, txt).attr({ fill: "#484848", font: "18px sans-serif" });

    var bb = popup_txt.getBBox();

    //draw path for tooltip box
    popup = paper.path(
        // 'M'ove to the 'dent' in the bubble
        "M" + (x) + " " + (y - 4) +
        // 'v'ertically draw a line 5 pixels more than the height of the text
        "v" + -(bb.height + 4) +
        // 'h'orizontally draw a line 10 more than the text's width
        "h" + (bb.width + 20) +
        // 'v'ertically draw a line to the bottom of the text
        "v" + (bb.height+4) +
        // 'h'orizontally draw a line so we're 5 pixels fro thge left side
        //"h" + -(bb.width + 5) +
        // 'Z' closes the figure  "#CADDF5"  "#767676"
        "Z").attr({ fill: "#fffff0", stroke: "#000000", "stroke-width": "0.2" });


    //finally put the text in front
    popup_txt.toFront();
    //Add class to highlight the text for the corresponding site, if found
    $("b:contains('" + txt + ":')").addClass('txtSiteHighlight');

}
function LoadProtocolSiteNodes() {
    var lymphNodes = $.parseJSON(regionPathsProtocolSites);
    for (i = 0; i < lymphNodes.length; i++) {

        var thisNode = paper.circle(lymphNodes[i]["XCoordinate"], lymphNodes[i]["YCoordinate"], siteRadius)
            .attr({
                fill: "yellow",
                cursor: "auto"
            });

        //Temp code - remove later
        $(thisNode.node).data('Region', lymphNodes[i]["Region"]);
        $(thisNode.node).data('RegionId', lymphNodes[i]["RegionId"]);

        $([thisNode.node]).SiteContextMenu({
            menu: 'ProtocolSiteClickMenu',
            onShow: onProtocolSiteContextMenuShow
        });
    }
}

Raphael.el.trigger = function (str/*name of event*/, scope) {
    scope = scope || this;
    for (var i = 0; i < this.events.length; i++) {
        if (this.events[i].name === str) {
            this.events[i].f.call(scope);
        }
    }
};

function fireEvent(element, event) {
    if (document.createEventObject) {
        // dispatch for IE
        var evt = document.createEventObject();
        return element.fireEvent('on' + event, evt)
    } else {
        // dispatch for firefox + others
        var evt = document.createEvent("HTMLEvents");
        evt.initEvent(event, true, true); // event type,bubbling,cancelable
        return !element.dispatchEvent(evt);
    }
}


//function DiagramClick() {

//}

var currentSite;
var tempRes;

function InsertSite(site) {

    //PageMethods.SaveSite();
    //alert($("#<%=PatientTextBox.ClientID%>"));
    //alert($("#DiagramDropDownList").val());
    //var pat = $("#PatientTextBox").val();
    //var proc = $("#DiagramDropDownList").val();

    //var patient = (pat == " -- New -- ") ? "" : pat;
    //var patient = $("#PatientTextBox").val();
    //var procedure = (proc == "-- Select --") ? "" : proc;
    var antpos = (site.data('AntPos') == 'Both / Either') ? " BothOrEither" : site.data('AntPos');
    var sitePositionAssigned = (site.data('PositionAssigned') == undefined) ? false : site.data('PositionAssigned');
    var regId = site.data('RegionId');
    var xy = site.data('Coordinates');
    var x = xy.split(",")[0];
    var y = xy.split(",")[1];
    var an = site.data('AreaNo');
    //alert(an);

    currentSite = site;

    var jsondata =
    {
        procId: procedureId,
        regionId: regId,
        xCd: x,
        yCd: y,
        position: antpos,
        areaNumber: an,
        height: diagramHeight,
        width: diagramWidth,
        positionSpecified: sitePositionAssigned
    };

    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/InsertSite",
        timeout: 3000,
        async: false,
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: InsertSiteComplete,
        error: function (jqXHR, textStatus, data) {
            //var vars = jqXHR.responseText.split("&"); 
            //alert(vars[0]); 
            alert("Unknown error occured while saving the site to the database. Please contact HD Clinical helpdesk.");
            LoadBasics();
            LoadExistingPatient();
        }
    });

}

function InsertLymphNodeSite(site) {

    //PageMethods.SaveSite();
    //alert($("#<%=PatientTextBox.ClientID%>"));
    //alert($("#DiagramDropDownList").val());
    //var pat = $("#PatientTextBox").val();
    //var proc = $("#DiagramDropDownList").val();

    //var patient = (pat == " -- New -- ") ? "" : pat;
    //var patient = $("#PatientTextBox").val();
    //var procedure = (proc == "-- Select --") ? "" : proc;
    var antpos = (site.data('AntPos') == 'Both / Either') ? " BothOrEither" : site.data('AntPos');
    var sitePositionAssigned = (site.data('PositionAssigned') == undefined) ? false : site.data('PositionAssigned');
    var lymphNodeId = site.data('LymphNodeId');
    var regId = site.data('RegionId');
    var xy = site.data('Coordinates');
    var x = xy.split(",")[0];
    var y = xy.split(",")[1];
    var an = site.data('AreaNo');
    //alert(an);

    currentSite = site;

    var jsondata =
    {
        procId: procedureId,
        regionId: regId,
        xCd: x,
        yCd: y,
        position: antpos,
        areaNumber: an,
        height: diagramHeight,
        width: diagramWidth,
        positionSpecified: sitePositionAssigned,
        lymphNodeId : lymphNodeId
    };

    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/InsertLymphNodeSite",
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: InsertSiteComplete,
        error: function (jqXHR, textStatus, data) {
            //var vars = jqXHR.responseText.split("&"); 
            //alert(vars[0]); 
            alert("Unknown error occured while saving the site to the database. Please contact HD Clinical helpdesk.");
            LoadBasics();
            LoadExistingPatient();
        }
    });

}

function InsertSiteComplete(jqXHR, textStatus, data) {
    //if (jqXHR.InsertSiteResult.indexOf("ErrorRef") > -1) {
    if (jqXHR.d.indexOf("ErrorRef") > -1) {
        ShowError("There is a problem saving the site to the database",
            //jqXHR.InsertSiteResult.replace("ErrorRef: ", ""));
            jqXHR.d.replace("ErrorRef: ", ""));
        LoadBasics();
        LoadExistingPatient();
    }
    else {
        //At the time of writing, the result is obtained as SITEID;SITETITLE
        //Example, 3;Site B
        //var res = jqXHR.InsertSiteResult;
        var res = jqXHR.d;
        var arr = res.split(';');
        currentSite.data('SiteId', arr[0]);
        currentSite.data('SiteTitle', arr[1]);

        var attsChanged = currentSite.data('AttributesChanged');
        if (attsChanged) {
            UpdateSite(currentSite);
        }


        //alert("---" + $(site.node).data('AreaNo'));
        //var xy = currentSite.data('Coordinates');
        //var x = xy.split(",")[0];
        //var y = xy.split(",")[1];
        if (markarea) {
            if (!isAreaFirstSite) { return; }
            isAreaFirstSite = false;
        }
        currentSite.hover(function () {

            //alert(currentSite.data('Coordinates').split(",")[0]);
            //alert(currentSite.data('Coordinates').split(",")[1]);
            //alert(this.cx.baseVal.value);
            //alert(this.cy.baseVal.value);
            //alert($(site.node).data('SiteTitle'));
            DrawTooltip(this, 1);
        },
            function () {
                DrawTooltip(this, 0);
            });

        RefreshSiteSummary();
        RefreshSiteTitles();

        if (currentSite.data('IsLymphNode') == true) {
            
            //refreshDiagram();

        }
        else {
            var reg;
            if (currentSite.data('RegionId') == -77) {
                reg = 'site by distance';
            }
            else {
                reg = $(site.node).data('Region');
            }
        }

        //Open SiteDetails window for sites outside diagram for EUS only: Check if procedureType is EUS (OGD [6] & HPB [7]). And region is 'Mediastinal' for EUS-OGD, 'Site' for EUS-HPB
        //if ((['6', '7'].indexOf(selectedProcType) >= 0) && (['Mediastinal', 'Site'].indexOf(reg) >= 0)) {
        //    OpenSiteDetails(reg, currentSite.data('SiteId'), reg);
        //}
        if (selectedProcType === "11") {
            AddLymphNodesForNewEbusProcedure();
        }
    }
}
function SaveResectedColon(resectedColonID) {
    var jsondata =
    {
        ProcedureID: procedureId,
        ColonResectionID: resectedColonID
    };
    tempRes = resectedColonID;
    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/UpdateResectedColon",
        timeout: 3000,
        async: false,
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: ResectedComplete,
        error: function (jqXHR, textStatus, data) {
            console.log(jqXHR);
            console.log(textStatus);
            alert("Unknown error occured while saving resected colon to the database. Please contact HD Clinical helpdesk.");
        }
    });

}
function ResectedComplete(jqXHR, textStatus, data) {
    if (jqXHR.d.indexOf("ErrorRef") > -1) {
        ShowError("There is a problem saving the resected colon to the database",
            //jqXHR.UpdateSiteResult.replace("ErrorRef: ", ""));
            jqXHR.d.replace("ErrorRef: ", ""));
    }
    else {
        resectionColonId = tempRes;
    }
}

function UpdateSite(site) {
    //alert('diagram.js:UpdateSite');
    var id = site.data('SiteId');
    var antpos = (site.data('AntPos') == 'Both / Either') ? " BothOrEither" : site.data('AntPos');
    var sitePositionAssigned = (site.data('PositionAssigned') == undefined) ? false : site.data('PositionAssigned');
    var regId = site.data('RegionId');
    var xy = site.data('Coordinates');
    var x = xy.split(",")[0];
    var y = xy.split(",")[1];

    currentSite = site;
    //alert('update23');
    var jsondata =
    {
        siteId: id,
        regionId: regId,
        xCd: x,
        yCd: y,
        position: antpos,
        positionSpecified: sitePositionAssigned
    };

    //alert(JSON.stringify(jsondata));     
    //url: webserviceUrl + '/UpdateSite',

    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/UpdateSite",
        timeout: 3000,
        async: false,
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: UpdateSiteComplete,
        error: function (jqXHR, textStatus, data) {
            //var vars = jqXHR.responseText.split("&"); 
            //alert(vars[0]); 
            alert("Unknown error occured while saving the site to the database. Please contact HD Clinical helpdesk.");
            LoadBasics();
            LoadExistingPatient();
        }
    });
}

function UpdateSiteComplete(jqXHR, textStatus, data) {
    //if (jqXHR.UpdateSiteResult.indexOf("ErrorRef") > -1) {
    if (jqXHR.d.indexOf("ErrorRef") > -1) {
        ShowError("There is a problem saving the site to the database",
            //jqXHR.UpdateSiteResult.replace("ErrorRef: ", ""));
            jqXHR.d.replace("ErrorRef: ", ""));
        LoadBasics();
        LoadExistingPatient();
    }
    else {
        RefreshSiteSummary();
        RefreshSiteTitles();
    }
}

function ShowError(headermsg, errorref) {
    var errorMsg = "<table>"
    errorMsg = errorMsg + "<tr><td colspan='2' class='aspxValidationSummaryHeader'>" + headermsg + "</td></tr>"
    errorMsg = errorMsg + "<tr><td><br/></td></tr>"
    errorMsg = errorMsg + "<tr><td colspan='2'>Please contact HD Clinical Helpdesk with the following details.</td></tr>"
    errorMsg = errorMsg + "<tr><td style='width:100px'>Error Reference:</td><td>" + errorref + "</td></tr>"
    errorMsg = errorMsg + "<tr><td>Procedure Id:</td><td>" + procedureId + "</td></tr>"
    errorMsg = errorMsg + "</table>"
    ShowErrorNotification(errorMsg);
}

function DeleteSiteByDistance(site) {
    var jsondata =
    {
        siteId: site.data('SiteId')
    };

    //alert(JSON.stringify(jsondata));
    //url: webserviceUrl + '/DeleteSite',
    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/DeleteSite",
        timeout: 3000,
        async: false,
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (jqXHR, textStatus, data) {
            //site.remove();
            RefreshSiteSummary();
            RefreshSiteTitles();
        },
        error: function (jqXHR, textStatus, data) {
            alert("Unknown error occured while deleting the site from the database. Please contact HD Clinical helpdesk.");
            LoadBasics();
            LoadExistingPatient();
        }
    });
}

function DeleteSite(site) {
    var areaMainSite = false;
    var message = "Are you sure you want to remove this site and all associated data if any?";

    if (site.data('AreaNo') > 0 && site.data('PartOfArea') == false) {
        message = "This is the main site of the area. Are you sure you want to remove the entire marked area?";
    }
    else if (site.data('AreaNo') > 0 && site.data('PartOfArea') == true) {
        message = "Are you sure you want to remove this site?";
    }

    if (confirm(message)) {

        // Remove the site from the array
        //independentSites.splice($.inArray(site, independentSites), 1);

        var jsondata =
        {
            siteId: site.data('SiteId')
        };
        //alert(JSON.stringify(jsondata));
        //url: webserviceUrl + '/DeleteSite',
        $.ajax({
            type: "POST",
            url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/DeleteSite",
            data: JSON.stringify(jsondata),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (jqXHR, textStatus, data) {
                DeleteSiteComplete(jqXHR, site);
            },
            error: function (jqXHR, textStatus, data) {
                alert("Unknown error occured while deleting the site from the database. Please contact HD Clinical helpdesk.");
                LoadBasics();
                LoadExistingPatient();
            }
        });
    }
}

function DeleteSiteComplete(jqXHR, site) {
    if (jqXHR.d.indexOf("ErrorRef") > -1) {
        ShowError("There is a problem deleting the site",
            jqXHR.d.replace("ErrorRef: ", ""));
        LoadBasics();
        LoadExistingPatient();
    }
    else {
        var isAreaMainSite = (site.data('AreaNo') > 0 && site.data('PartOfArea') == false);
        var l1, l2;
        var index;
        var mySites, myRaphId;

        var myInfo = getCurrentSiteInfo(paper.getById(site[0].raphaelid));
        if (myInfo != null) {
            this.siteInfo = myInfo[0];
            this.areaInfo = myInfo[1];
        }

        if (this.areaInfo != null && this.areaInfo != 'undefined') {
            mySites = this.areaInfo.areaSites;
            myRaphId = this.areaInfo.raphId;
        }
        else {
            mySites = linkedSites;
            myRaphId = areaId;
        }

        if (isAreaMainSite == true) {
            for (var i = 0; i < mySites.length; i++) {
                var siteElem = mySites[i].siteElement;
                var ln1 = mySites[i].line1;
                var ln2 = mySites[i].line2;

                if (typeof ln1 != 'undefined') {
                    if (ln1 != null) {
                        ln1.remove();
                    }
                }
                if (typeof ln2 != 'undefined') {
                    if (ln2 != null) {
                        ln2.remove();
                    }
                }
                if (siteElem != null) {
                    siteElem.remove();
                }
            }
            if (typeof myRaphId != 'undefined' && myRaphId > 0) {
                var areaElem = paper.getById(myRaphId);
                if (areaElem != null) {
                    areaElem.remove();
                }
            }
        }
        else {
            for (var i = 0; i < mySites.length; i++) {
                if (mySites[i].siteElement == (paper.getById(site[0].raphaelid))) {
                    index = i;
                    break;
                }
            }

            if (index > -1) {
                mySites.splice(index, 1);
            }

            if (typeof myRaphId != 'undefined' && myRaphId > 0) {
                var areaElem = paper.getById(myRaphId);
                if (areaElem != null) {
                    areaElem.remove();
                }
            }

            if (this.siteInfo != undefined) {
                l1 = this.siteInfo["line1"];
                l2 = this.siteInfo["line2"];

                if (typeof l1 != 'undefined') {
                    if (l1 != null) {
                        l1.remove();
                    }
                }
                if (typeof l2 != 'undefined') {
                    if (l2 != null) {
                        l2.remove();
                    }
                }
            }

            site.remove();
            id = id - 1;
            ReMarkArea(this.areaInfo, index);
        }
        
        RefreshSiteSummary();
        RefreshSiteTitles();
        refreshParent();
    }
}

function RefreshSiteTitles() {
    var titlesUrl = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/GetSiteTitles";
    var jsondata =
    {
        procId: procedureId
    };

    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/GetSiteTitles",
        timeout: 3000,
        async: false,
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (jqXHR, textStatus, data) {
            RefreshSiteTitlesComplete(jqXHR, textStatus, data);
        },
        error: function (jqXHR, textStatus, data) {
            alert("Unknown error occured while retrieving data. Please contact HD Clinical helpdesk.");
            LoadBasics();
            LoadExistingPatient();
        }
    });
}

function RefreshSiteTitlesComplete(jqXHR, textStatus, data) {
    if (jqXHR.d.indexOf("ErrorRef") > -1) {
        ShowError("There is a problem retrieving data.",
            jqXHR.d.replace("ErrorRef: ", ""));
    }
    else {
        var newTitles = $.parseJSON(data.responseJSON.d);

        independentSites.forEach(function (mySite) {
            var titleObj = jQuery.grep(newTitles, function (item, i) {
                return (item.SiteId == $(mySite.node).data('SiteId'));
            });

            if (titleObj[0] != undefined) {
                $(mySite.node).data('SiteTitle', titleObj[0].SiteTitle);
            }
        });

        areas.forEach(function (myArea) {
            myArea.areaSites.forEach(function (mySite) {
                var titleObj = jQuery.grep(newTitles, function (item, i) {
                    return (item.SiteId == $(mySite.siteElement.node).data('SiteId'));
                });

                if (titleObj[0] != undefined) {
                    $(mySite.siteElement.node).data('SiteTitle', titleObj[0].SiteTitle);
                }
            });
        });

        linkedSites.forEach(function (mySite) {
            var titleObj = jQuery.grep(newTitles, function (item, i) {
                return (item.SiteId == $(mySite.siteElement.node).data('SiteId'));
            });

            if (titleObj[0] != undefined) {
                $(mySite.siteElement.node).data('SiteTitle', titleObj[0].SiteTitle);
            }
        });
    }
}

function ReMarkArea(affectedArea, deletedIndex) {

    var prev, next;
    //if (deletedIndex > 0) {
    //    prev = affectedArea.areaSites[deletedIndex - 1];
    //}
    //else {
    //    prev = affectedArea.areaSites[affectedArea.areaSites.length - 1]
    //}
    if (affectedArea != null && affectedArea != undefined) {
        prev = affectedArea.areaSites[deletedIndex - 1];
        next = affectedArea.areaSites[deletedIndex];
        affectedArea.areaSites.forEach(function (site) {
            if (site.id >= deletedIndex + 1) {
                site.id = site.id - 1;
            }
        });
    }
    else {
        prev = linkedSites[deletedIndex - 1];
        next = linkedSites[deletedIndex];
        linkedSites.forEach(function (site) {
            if (site.id >= deletedIndex + 1) {
                site.id = site.id - 1;
            }
        });
    }

    if (prev != undefined && next != undefined) {
        var newLine = paper.path("M" + $(prev.siteElement.node).data("Coordinates") + " L" + $(next.siteElement.node).data("Coordinates"))
            .attr({ "stroke": "red" });

        prev.line2 = newLine;
        prev.pathArray2 = newLine.attr("path");
        next.line1 = newLine;
        next.pathArray1 = newLine.attr("path");

        if (affectedArea != null && affectedArea != undefined) {
            isCloseEnough(affectedArea.areaNum);
        }
        else {
            isCloseEnough();
        }
    }

    //alert(myArea.areaSites.length);
    //var matches = jQuery.grep(areas, function () {
    //    return (this.areaNum === arNumber);
    //});

    //if (matches.length) {
    //    myArea = matches[0];
    //}

}

//function a(s) {
//    //alert(s);
//    s.animate({r : 8}, 3000, b(s));
//}

//function b(s) {
//    //alert(0);
//    s.animate({r : 5}, 300, a(s));
//}

//$(linkedSites).contextMenu({
//    menu: 'menuCircle',
//    onShow: onContextMenuShow,
//    onSelect: onContextMenuItemSelect
//});

//function onContextMenuShow(target, pos) {
//    //alert("show");
//}

//function onContextMenuItemSelect(menuitem, target, href, pos) {
//    //alert("select");
//}

function BuildRegions() {
    //var regions = getRegionData();
    var regs = $.parseJSON(regionPaths);
    for (i = 0; i < regs.length; i++) {
        var thisPath = paper.path(regs[i]["Path"]);
        //thisPath.attr({ "id": "hey" });
        //thisPath.id = regs[i]["name"];
        //thisPath.name = regs[i]["name"];
        //thisPath.attr({ "stroke-width": "1", "id": "test" });
        thisPath.attr({ "stroke-width": "1", "stroke": "red" });
        //thisPath.attr({ "stroke-width": 1, "fill": "blue" });
        //thisPath.hide();
        var name = regs[i]["Region"];
        thisPath.data({ "id": regs[i]["Region"] });
        //thispath.attr(style);
        //thisPath.data({ "name": "hey" });
        //thisPath.data('custom-attribute', 'value');
        //thisPath["custom-attribute"] = "value";

        //thisPath.mouseover(function (e) {
        //    //alert(this.data("id"));
        //    $("#positionLabel").text(this.data("id"));
        //});

        //thisPath.onmouseover = function () {
        //    current && aus[current].animate({ fill: "#333", stroke: "#666" }, 500) && (document.getElementById(current).style.display = "");
        //    st.animate({ fill: st.color, stroke: "#ccc" }, 500);
        //    st.toFront();
        //    R.safari();
        //    document.getElementById(state).style.display = "block";
        //    current = state;
        //};

        //thisPath.mouseout(function (e) {
        //    //alert(this.data("id"));
        //    $("#positionLabel").text("No site");
        //});

        regions.push(thisPath);
        //thisPath.mouseover(function () { alert("hey"); });
        //thisPath.mousemove
        //thisPath.node.onclick = function () {
        //    thispath.attr("fill", "red");
        //}
        //thisPath.mouseover(function (e) {
        //    this.node.style.opacity = 0.7;
        //    //document.getElementById('region-name').innerHTML = this.data('region');
        //});

        //thisPath.mouseout(function (e) {
        //    this.node.style.opacity = 1;
        //});

        //var animationSpeed = 500;
        //var hoverStyle = {
        //    fill: "#A8BED5"
        //}

        //for (var regionName in regions) {
        //    (function (region) {
        //        region.attr(style);

        //        region[0].addEventListener("mouseover", function () {
        //            region.animate(hoverStyle, animationSpeed);
        //        }, true);

        //        region[0].addEventListener("mouseout", function () {
        //            region.animate(style, animationSpeed);
        //        }, true);

        //    })(regions[regionName]);
        //}
    }
    regionsExist = true;

    //var current = null;
    //for (var state in regions) {
    //    regions[state].color = Raphael.getColor();
    //    (function (st, state) {
    //        st[0].style.cursor = "pointer";
    //        st[0].onmouseover = function () {
    //            //current && regions[current].animate({fill: "#333", stroke: "#666"}, 500) && (document.getElementById(current).style.display = "");
    //            st.animate({ fill: st.color, stroke: "#ccc" }, 500);
    //            st.toFront();
    //            R.safari();
    //            document.getElementById(state).style.display = "block";
    //            current = state;
    //        };
    //        st[0].onmouseout = function () {
    //            st.animate({fill: "#333", stroke: "#666"}, 500);
    //            st.toFront();
    //            R.safari();
    //        };
    //        if (state == "nsw") {
    //            st[0].onmouseover();
    //        }
    //    })(regions[state], state);
    //}
    return false;
}

function GetRegion(x, y) {
    //var regionData = getRegionData();
    var regionData = $.parseJSON(regionPaths);
    var regionName = "";
    var regionId = "";
    is3D = false;
    for (i = 0; i < regionData.length; i++) {
        var isinside = Raphael.isPointInsidePath(regionData[i]["Path"], x, y);
        if (isinside) {
            regionName = regionData[i]["Region"];

            //Terminal Ileum is named different depending on resection so needs handeling so region name is displayed correctly
            if ((resectionColonId == 6 || resectionColonId == 7) && regionName == "Terminal Ileum")
                regionName = "Neo-Terminal Ileum";
            else if (resectionColonId == 9 && regionName == "Terminal Ileum")
                regionName = "Ileal Pouch";

            regionId = regionData[i]["RegionId"];
            if (regionData[i]["is3D"]) { is3D = true; }
            return regionId + ";" + regionName;
        }
    }
    //$("#positionLabel").text(regionName);
    return "";
}

function isWithinRegions(x, y) {
    //var regionData = getRegionData();
    var regionData = $.parseJSON(regionPaths);
    for (i = 0; i < regionData.length; i++) {
        var isinside = Raphael.isPointInsidePath(regionData[i]["Path"], x, y);
        if (isinside) {
            return true;
        }
    }
    return false;
}

function ClearRegions() {
    regions.forEach(function (reg) {
        reg.remove();
    });
    regionsExist = false;
}

function getCurrentSiteInfo(val) {

    //for (var i in linkedSites) {
    //    alert(linkedSites[key]);
    //    if (i == key && linkedSites[key] === val) {

    //        return linkedSites[i];
    //    }
    //}
    //var arrayOfObjects = [{ "id": 28, "Title": "Sweden" }, { "id": 56, "Title": "USA" }, { "id": 89, "Title": "England" }];


    // Independent sites i.e., the sites that do not make an area. Return null in this case because there is no SiteInfo (i.e., lines, patharrays etc).
    for (var i = 0; i < independentSites.length; i++) {
        if (independentSites[i] == val) {
            return [null, null];
        }
    }

    // Existing areas
    for (var i = 0; i < areas.length; i++) {
        var myAreaNumber = areas[i].areaNum;
        var mySites = areas[i].areaSites;
        for (var j = 0; j < mySites.length; j++) {
            var object = mySites[j];
            if (object["siteElement"] == val) {
                return [object, areas[i]];
            }
            //for (var property in object) {
            //    if (property == key) {
            //        if (object[property] == val) {
            //            return [object, areas[i]];
            //        }
            //    }
            //}
        }
    }

    // Current area that is being drawn
    for (var i = 0; i < linkedSites.length; i++) {
        var object = linkedSites[i];
        if (object["siteElement"] == val) {
            return [object, null];
        }
        //for (var property in object) {
        //    if (property == key) {
        //        if (object[property] == val) {
        //            return [object, null];
        //        }
        //    }
        //}
    }


    //if (areas.length == 0) {
    //    for (var i = 0; i < linkedSites.length; i++) {
    //        var object = linkedSites[i];
    //        for (var property in object) {
    //            if (property == key) {
    //                if (object[property] == val) {
    //                    return object;
    //                }
    //            }
    //        }
    //    }
    //}
    //else {

    //    for (var i = 0; i < areas.length; i++) {
    //        var mySites = areas[i].areaSites;
    //        for (var j = 0; j < mySites.length; j++) {
    //            var object = mySites[j];
    //            for (var property in object) {
    //                if (property == key) {
    //                    if (object[property] == val) {
    //                        return object;
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}
}

function getAreaSitesBySite(val) {
    // Existing areas
    for (var i = 0; i < areas.length; i++) {
        var myAreaNumber = areas[i].areaNum;
        var mySites = areas[i].areaSites;
        for (var j = 0; j < mySites.length; j++) {
            var object = mySites[j];
            if (object["siteElement"] == val) {
                return areas[i].areaSites;
            }
        }
    }
}

function shadearea(sitesCollection) {
    //var compath = "M";
    //for (var i = 0; i < sitecoords.length; i++) {
    //    if (i == 0) {
    //        compath = compath + sitecoords[i];
    //    }
    //    else {
    //        compath = compath + ", " + sitecoords[i];
    //    }
    //}
    //compath = compath + "z";

    //alert(compath);

    ////Create shaded area
    //area = paper.path(compath)
    //.attr({ "stroke": "red", "fill": "#F7C3C6" });

    //Get complete path
    var compath = "M ";
    var area;

    for (var i = 0; i < sitesCollection.length; i++) {
        var s = sitesCollection[i];
        if (i == 0) {
            //compath = compath + s["siteCoord"];
            compath = compath + $(s.siteElement.node).data("Coordinates");
        }
        else {
            //compath = compath + ", " + s["siteCoord"];
            compath = compath + ", " + $(s.siteElement.node).data("Coordinates");
        }
    }
    compath = compath + " z";
    //alert(compath);
    //Create shaded area
    area = paper.path(compath)
        //.attr({ "stroke": "red", "fill": "#FF8B8B" })
        //.attr('class', 'area-marked')

        //.click(DiagramClick(this));
        //.click(DiagramClick);
        .click(function () {
            diagram.trigger('click', diagram);
        });

    $(area.node).attr('class', 'area-marked');

    //areaId = area.node.raphaelid;

    //Bring the sites to the front
    sitesCollection.forEach(function (site) {
        //alert(0);

        var elem = site["siteElement"];
        elem.toFront();
        //elem.node.parentNode.appendChild(elem.node);
        //elem.click(function () { alert("yoyo") });
        //elem.node.toFront();
        //alert(elem.node);
    });

    // Bring the first site of the collection to front
    sitesCollection[0].siteElement.toFront();

    independentSites.forEach(function (site) {
        var isinside = Raphael.isPointInsidePath(compath, $(site.node).data('Coordinates').split(",")[0], $(site.node).data('Coordinates').split(",")[1]);
        if (isinside) {
            site.toFront();
        }
    });

    //sitesCollection[0]["siteElement"].toFront();

    //var gogo = paper.getById(sitesCollection[0]["siteElement"].node.raphaelid);
    //gogo.toFront();

    return area.node.raphaelid;

    ////Get complete path
    //var compath = "M ";
    //for (var i = 0; i < sitecoords.length; i++) {
    //    if (i == 0) {
    //        compath = compath + sitecoords[i];
    //    }
    //    else {
    //        compath = compath + ", " + sitecoords[i];
    //    }
    //}
    //compath = compath + " z";

    ////areaPath = compath;

    ////Create shaded area
    //area = paper.path(compath)
    //.attr({ "stroke": "red", "fill": "#E6E680" })


    ////.click(DiagramClick(this));
    ////.click(DiagramClick);
    //.click(function () {

    //    //fireEvent(diagram.node, 'click');
    //    diagram.trigger('click', diagram);
    //    //diagram.events[0].f();
    //    //$(diagram.node)[0].trigger('click');
    //    //$(diagram)[0].events[1][Methods].f();

    //});

    ////.click({ areaPath: "Hello" }, DiagramClick);
    ////area.node.id = 'myarea';
    ////$('#myarea').bind('click', { areaPath: "Hello" }, DiagramClick);
    ////$('#myarea').click({ areaPath: compath }, DiagramClick);

    ////alert(area.attr('path'));
    ////.click(function () {
    ////    var bnds = event.target.getBoundingClientRect();
    ////    var mx = event.clientX - bnds.left;
    ////    var my = event.clientY - bnds.top;

    ////    var gogosite = paper.circle(mx, my, siteRadius)
    ////    .attr({
    ////        fill: "white",
    ////        cursor: "pointer"
    ////    });
    ////});

    //areaId = area.node.raphaelid;

    ////Bring the sites to the front
    //linkedSites.forEach(function (site) {
    //    var elem = site["siteElement"];
    //    elem.toFront();
    //    //elem.node.toFront();
    //    //alert(elem.node);
    //});
}

function isCloseEnough(areaNo) {
    //remove the existing shaded area first
    //if (typeof areaId != 'undefined' && areaId > 0) {
    //    var areaElem = paper.getById(areaId);
    //    if (areaElem != null) {
    //        areaElem.remove();
    //        areaId = 0;
    //    }
    //}

    var myArea;
    var myAreaRaphId;
    var mySites;
    var indexFound = -1;

    if (areaNo != undefined) {
        for (var i = 0; i < areas.length; i++) {
            if (areas[i]["areaNum"] == areaNo) {
                myArea = areas[i];
                indexFound = i;
                break;
            }
        }
        if (myArea != undefined) {
            //myAreaRaphId = myArea["raphId"];
            myAreaRaphId = myArea.raphId;
            mySites = myArea.areaSites;
        }
    }
    else {
        myAreaRaphId = areaId;
        mySites = linkedSites;
    }

    if (typeof myAreaRaphId != 'undefined' && myAreaRaphId > 0) {
        var areaElem = paper.getById(myAreaRaphId);
        if (areaElem != null) {
            areaElem.remove();
            if (areaNo != undefined) {
                areaId = 0;
            }
        }
    }

    //create a new shaded area when the first and last sites are close enough
    var firstsitex, firstsitey, lastsitex, lastsitey, newx, newy;
    var diffx, diffy;
    var currentSiteIndex = -1;
    var correspondingLine;
    if (mySites.length >= 3) {

        //diffx = mySites[0].siteCoord.split(",")[0] - mySites[mySites.length - 1].siteCoord.split(",")[0];
        //diffy = mySites[0].siteCoord.split(",")[1] - mySites[mySites.length - 1].siteCoord.split(",")[1];

        if (site != null) {
            for (var i = 0; i < mySites.length; i++) {
                if (mySites[i].siteElement == (paper.getById(site[0].raphaelid))) {
                    currentSiteIndex = i;
                    break;
                }
            }
        }

        //if (currentSiteIndex > -1) {

        firstsitex = +$(mySites[0].siteElement.node).data("Coordinates").split(",")[0];
        firstsitey = +$(mySites[0].siteElement.node).data("Coordinates").split(",")[1];
        lastsitex = +$(mySites[mySites.length - 1].siteElement.node).data("Coordinates").split(",")[0];
        lastsitey = +$(mySites[mySites.length - 1].siteElement.node).data("Coordinates").split(",")[1];

        //diffx = $(mySites[0].siteElement.node).data("Coordinates").split(",")[0] - $(mySites[mySites.length - 1].siteElement.node).data("Coordinates").split(",")[0];
        //diffy = $(mySites[0].siteElement.node).data("Coordinates").split(",")[1] - $(mySites[mySites.length - 1].siteElement.node).data("Coordinates").split(",")[1];
        diffx = firstsitex - lastsitex;
        diffy = firstsitey - lastsitey;

        if ((diffx >= -10 && diffx <= 10) && (diffy >= -10 && diffy <= 10)) {
            //$(mySites[mySites.length - 1].siteElement.node).data("Coordinates", firstsitex + "," + firstsitey);
            //$(linkedSites[mySites.length - 1].siteElement.node).data("Coordinates", firstsitex + "," + firstsitey);

            if (currentSiteIndex == 0 || currentSiteIndex == mySites.length - 1) {
                if (currentSiteIndex == mySites.length - 1) {
                    newx = firstsitex;
                    newy = firstsitey;
                    correspondingLine = getCurrentSiteInfo(site)[0]["line1"];;
                }
                else if (currentSiteIndex == 0) {
                    newx = lastsitex;
                    newy = lastsitey;
                    correspondingLine = getCurrentSiteInfo(site)[0]["line2"];
                }

                $(mySites[currentSiteIndex].siteElement.node).data("Coordinates", newx + "," + newy);
                //$(linkedSites[currentSiteIndex].siteElement.node).data("Coordinates", newx + "," + newy);

                //site.attr('class', 'site-Dragging');
                $(site.node).data("Coordinates", newx + "," + newy);

                var att = {
                    cx: newx,
                    cy: newy,
                };
                site.attr(att);
                $(site.node).data('AttributesChanged', true);
                //site.toFront();
                //site.toBack();
                //mySites[0].siteElement.toFront();

                //site.translate(diffx, diffy);
                if (currentSiteIndex == mySites.length - 1) {
                    correspondingLine.remove();

                    var prevSiteCoordinates = $(mySites[currentSiteIndex - 1].siteElement.node).data("Coordinates");
                    var nline = paper.path("M" + prevSiteCoordinates + " L" + newx + "," + newy);

                    nline.attr({ "stroke": "red" });

                    mySites[currentSiteIndex - 1].line2 = nline;
                    mySites[currentSiteIndex - 1].pathArray2 = nline.attr("path");

                    mySites[currentSiteIndex].line1 = nline;
                    mySites[currentSiteIndex].pathArray1 = nline.attr("path");
                }
                else {
                    correspondingLine.remove();

                    var nextSiteCoordinates = $(mySites[1].siteElement.node).data("Coordinates");
                    var nline = paper.path("M" + newx + "," + newy + " L" + nextSiteCoordinates);

                    nline.attr({ "stroke": "red" });

                    mySites[0].line2 = nline;
                    mySites[0].pathArray2 = nline.attr("path");
                    //linkedSites[0].line2 = nline;
                    //linkedSites[0].pathArray2 = nline.attr("path");

                    mySites[1].line1 = nline;
                    mySites[1].pathArray1 = nline.attr("path");
                    //linkedSites[1].line1 = nline;
                    //linkedSites[1].pathArray1 = nline.attr("path");
                }
                //UpdateSite($(site.node));
            }

            myAreaRaphId = shadearea(mySites);
            if (indexFound > -1) {
                areas[indexFound]["raphId"] = myAreaRaphId;
            }
            else {
                areaId = myAreaRaphId;
            }
            return true;
        }
        return false;
    }

    ////create a new shaded area when the first and last sites are close enough
    //var diffx, diffy;
    //if (sitecoords.length >= 3) {
    //    diffx = sitecoords[0].split(",")[0] - sitecoords[sitecoords.length - 1].split(",")[0];
    //    diffy = sitecoords[0].split(",")[1] - sitecoords[sitecoords.length - 1].split(",")[1];

    //    if ((diffx >= -10 && diffx <= 10) && (diffy >= -10 && diffy <= 10)) {
    //        shadearea();
    //        return;
    //    }
    //}
}

$(document).ready(function () {
    //$("#PatientCheckBox").change(function () {
    //    if (this.checked) {
    //        //$("#PatientTextBox").val("")
    //        $("#PatientTextBox").attr("disabled", "disabled");
    //    }
    //    else {
    //        $("#PatientTextBox").removeAttr("disabled");
    //    }
    //})

    $("#ctl00_LeftPaneContentPlaceHolder_AddSiteButton_input").click(function (event) {
        alert('#ctl00_LeftPaneContentPlaceHolder_AddSiteButton_input');
        addsite = true;
        event.preventDefault();

    });

    $("#ctl00_LeftPaneContentPlaceHolder_MarkAreaButton_input").click(function (event) {
        //var $self = $(this);
        //if ($self.val() == "Mark Area") {
        //    $("#addSiteButton").prop("disabled", true);
        //    $self.val("Done");
        //    markarea = true;
        //    addsite = false;

        //    InitialiseArea();
        //}
        //else {
        //    if (arNo > 0) {
        //        var a = {
        //            areaNum: arNo,
        //            areaSites: linkedSites,
        //            raphId: areaId
        //        }
        //        areas.push(a);
        //    }

        //    markarea = false;
        //    $self.val("Mark Area");
        //    $("#addSiteButton").prop("disabled", false);
        //}

        //var btn = $find("ctl00_LeftPaneContentPlaceHolder_MarkAreaButton_input");
        //if (btn.get_text() == "Mark Area") {
        //if (this.value == "Mark Area") {

        if ($(this).attr("value") == "Mark Area") {
            $find("ctl00_LeftPaneContentPlaceHolder_AddSiteButton").set_enabled(false);
            $find("ctl00_LeftPaneContentPlaceHolder_RemoveSiteButton").set_enabled(false);
            $find("ctl00_LeftPaneContentPlaceHolder_PhotosButton").set_enabled(false);
            $find("ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton").set_enabled(false);
            $find("ctl00_LeftPaneContentPlaceHolder_ResectedColonButton").set_enabled(false);
            $find("ctl00_LeftPaneContentPlaceHolder_ByDistanceButton").set_enabled(false);
            //btn.set_text("Done");
            $(this).prop('value', 'Done');
            markarea = true;
            addsite = false;
            isAreaFirstSite = true;
            InitialiseArea();
        }
        else {
            if (arNo > 0) {
                var a = {
                    areaNum: arNo,
                    areaSites: linkedSites,
                    raphId: areaId
                }
                areas.push(a);
            }

            markarea = false;
            //btn.set_text("Mark Area");
            $(this).prop('value', 'Mark Area');
            $find("ctl00_LeftPaneContentPlaceHolder_AddSiteButton").set_enabled(true);
            $find("ctl00_LeftPaneContentPlaceHolder_RemoveSiteButton").set_enabled(true);
            $find("ctl00_LeftPaneContentPlaceHolder_PhotosButton").set_enabled(true);
            $find("ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton").set_enabled(true);
            $find("ctl00_LeftPaneContentPlaceHolder_ResectedColonButton").set_enabled(true);
            $find("ctl00_LeftPaneContentPlaceHolder_ByDistanceButton").set_enabled(true);
        }
        event.preventDefault();
    });

    $("#ctl00_LeftPaneContentPlaceHolder_RemoveSiteButton_input").click(function (event) {
        //$("#confirmDiv").dialog();
        if (activeSite) {
            //if (confirm('Are you sure you want to remove this site and all associated data if any?')) {
            //    DeleteSite($(activeSite.node));
            //}
            DeleteSite($(activeSite.node));
        }
        event.preventDefault();
    });

    //$("#ctl00_LeftPaneContentPlaceHolder_Flip180Button_input").click(function (event) {
    //    location.reload(true);
    //    //event.preventDefault();
    //});

    $(document.getElementById('IntactColonImg')).click(function (event) {
        if (resectedColonSet.has(0)) {
            resectedColonSet.delete(0);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(0);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('AbdominoPerinealImg')).click(function (event) {
        if (resectedColonSet.has(1)) {
            resectedColonSet.delete(1);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(1);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('LowAnteriorImg')).click(function (event) {
        if (resectedColonSet.has(2)) {
            resectedColonSet.delete(2);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(2);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('SigmoidColectomyImg')).click(function (event) {
        if (resectedColonSet.has(3)) {
            resectedColonSet.delete(3);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(3);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('HighAnteriorImg')).click(function (event) {
        if (resectedColonSet.has(4)) {
            resectedColonSet.delete(4);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(4);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('HartmannsProcedureImg')).click(function (event) {
        if (resectedColonSet.has(12)) {
            resectedColonSet.delete(12);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(12);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('LeftHemicolectomyImg')).click(function (event) {
        if (resectedColonSet.has(11)) {
            resectedColonSet.delete(11);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(11);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('TransverseColectomyCanvasImg')).click(function (event) {
        if (resectedColonSet.has(5)) {
            resectedColonSet.delete(5);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(5);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('RightHemicolectomyImg')).click(function (event) {
        if (resectedColonSet.has(6)) {
            resectedColonSet.delete(6);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(6);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('ExtendedRightHemicolectomyImg')).click(function (event) {
        if (resectedColonSet.has(7)) {
            resectedColonSet.delete(7);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(7);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('SubtotalColectomyImg')).click(function (event) {
        if (resectedColonSet.has(8)) {
            resectedColonSet.delete(8);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(8);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('SubtotalColectomyStumpImg')).click(function (event) {
        if (resectedColonSet.has(13)) {
            resectedColonSet.delete(13);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(13);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('TotalColectomyImg')).click(function (event) {
        if (resectedColonSet.has(9)) {
            resectedColonSet.delete(9);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(9);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('PanProctoColectomyImg')).click(function (event) {
        if (resectedColonSet.has(10)) {
            resectedColonSet.delete(10);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(10);
            AddHighLights(this);
        }
        fillResection();
    });
    $(document.getElementById('IleocaecectomyImg')).click(function (event) {
        if (resectedColonSet.has(14)) {
            resectedColonSet.delete(14);
            RemoveHighlights(this);
        } else {
            resectedColonSet.add(14);
            AddHighLights(this);
        }
        fillResection();
    });


    function AddHighLights(element) {
        $(element).addClass('selectedimg');
        $(element).parent().siblings(".txtResectedColons").addClass('txtResectedColonsHighlighted');
        $(element).closest(".bgResectedColons").addClass('bgResectedColonsHighlighted');
    }

    function RemoveHighlights(element) {
        $(element).removeClass('selectedimg');
        $(element).parent().siblings(".txtResectedColons").removeClass('txtResectedColonsHighlighted');
        $(element).closest(".bgResectedColons").removeClass('bgResectedColonsHighlighted');
    }



    $("#ctl00_LeftPaneContentPlaceHolder_ResectedColonButton_input").click(function (event) {


        canvg(document.getElementById('IntactColonCanvas'), drawMiniCanvas(0));
        canvg(document.getElementById('AbdominoPerinealCanvas'), drawMiniCanvas(1));
        canvg(document.getElementById('LowAnteriorCanvas'), drawMiniCanvas(2));
        canvg(document.getElementById('SigmoidColectomyCanvas'), drawMiniCanvas(3));
        canvg(document.getElementById('HighAnteriorCanvas'), drawMiniCanvas(4));
        canvg(document.getElementById('HartmannsProcedureCanvas'), drawMiniCanvas(12));
        canvg(document.getElementById('LeftHemicolectomyCanvas'), drawMiniCanvas(11));
        canvg(document.getElementById('TransverseColectomyCanvas'), drawMiniCanvas(5));
        canvg(document.getElementById('RightHemicolectomyCanvas'), drawMiniCanvas(6));
        canvg(document.getElementById('ExtendedRightHemicolectomyCanvas'), drawMiniCanvas(7));
        canvg(document.getElementById('SubtotalColectomyCanvas'), drawMiniCanvas(8));
        canvg(document.getElementById('SubtotalColectomyStumpCanvas'), drawMiniCanvas(13));
        canvg(document.getElementById('TotalColectomyCanvas'), drawMiniCanvas(9));
        canvg(document.getElementById('PanProctoColectomyCanvas'), drawMiniCanvas(10));
        canvg(document.getElementById('IleocaecectomyCanvas'), drawMiniCanvas(14));


        setTimeout(function () {
            //fetch the dataURL from the canvas and set it as src on the image
            //var dataURL = document.getElementById('myCanvas1').toDataURL("image/png");
            document.getElementById('IntactColonImg').src = document.getElementById('IntactColonCanvas').toDataURL("image/png");
            document.getElementById('AbdominoPerinealImg').src = document.getElementById('AbdominoPerinealCanvas').toDataURL("image/png");
            document.getElementById('LowAnteriorImg').src = document.getElementById('LowAnteriorCanvas').toDataURL("image/png");
            document.getElementById('SigmoidColectomyImg').src = document.getElementById('SigmoidColectomyCanvas').toDataURL("image/png");
            document.getElementById('HighAnteriorImg').src = document.getElementById('HighAnteriorCanvas').toDataURL("image/png");
            document.getElementById('HartmannsProcedureImg').src = document.getElementById('HartmannsProcedureCanvas').toDataURL("image/png");
            document.getElementById('LeftHemicolectomyImg').src = document.getElementById('LeftHemicolectomyCanvas').toDataURL("image/png");
            document.getElementById('TransverseColectomyCanvasImg').src = document.getElementById('TransverseColectomyCanvas').toDataURL("image/png");
            document.getElementById('RightHemicolectomyImg').src = document.getElementById('RightHemicolectomyCanvas').toDataURL("image/png");
            document.getElementById('ExtendedRightHemicolectomyImg').src = document.getElementById('ExtendedRightHemicolectomyCanvas').toDataURL("image/png");
            document.getElementById('SubtotalColectomyImg').src = document.getElementById('SubtotalColectomyCanvas').toDataURL("image/png");
            document.getElementById('SubtotalColectomyStumpImg').src = document.getElementById('SubtotalColectomyStumpCanvas').toDataURL("image/png");
            document.getElementById('TotalColectomyImg').src = document.getElementById('TotalColectomyCanvas').toDataURL("image/png");
            document.getElementById('PanProctoColectomyImg').src = document.getElementById('PanProctoColectomyCanvas').toDataURL("image/png");
            document.getElementById('IleocaecectomyImg').src = document.getElementById('IleocaecectomyCanvas').toDataURL("image/png");
        }, 200);
        //var p1 = new Raphael(0, 0, 100, 100);
        //var set = p1.set();
        //p1.importSVG(sv,set);
        //var d1 =p1.image(sv, 0, 0, 100, 100);   
        //document.getElementById('DiagramDiv1').innerHTML = sv;
    });

    $("#ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton_input").click(function (event) {
        if (regionsExist == false) {
            BuildRegions();
        }
        else {
            fillResection();
        }
        //var $self = $(this);
        //if ($self.val() == "Show Regions") {
        //    $self.val("Hide Regions");
        //}
        //else {
        //    $self.val("Show Regions");
        //}
        var btn = $find("ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton_input");
        //if (btn.get_text() == "Show Regions") {
        //if ($(this).attr("value") == "Show Reg") {
        //    //btn.set_text("Hide Regions");
        //    $(this).prop('value', 'Hide Reg');
        //}
        //else {
        //    //btn.set_text("Show Regions");
        //    $(this).prop('value', 'Show Reg');
        //}
        event.preventDefault();
    });
});

//$(function () {
//    $("#confirmDiv").dialog({
//        resizable: false,
//        height: 140,
//        modal: true,
//        buttons: {
//            "Delete all items": function () {
//                $(this).dialog("close");
//            },
//            Cancel: function () {
//                $(this).dialog("close");
//            }
//        }
//    });
//});

//var svg = document.getElementsByTagName('svg')[0];
//for (var a = svg.querySelectorAll('.drag'), i = 0, len = a.length; i < len; ++i) {
//    (function (el) {
//        //var onmove; // make inner closure available for unregistration
//        el.addEventListener('mousedown', function (e) {
//            el.parentNode.appendChild(el); // move to top
//            //var x = el.tagName == 'circle' ? 'cx' : 'x';
//            //var y = el.tagName == 'circle' ? 'cy' : 'y';
//            //var mouseStart = cursorPoint(e);
//            //var elementStart = { x: el[x].animVal.value, y: el[y].animVal.value };
//            //onmove = function (e) {
//            //    var current = cursorPoint(e);
//            //    pt.x = current.x - mouseStart.x;
//            //    pt.y = current.y - mouseStart.y;
//            //    var m = el.getTransformToElement(svg).inverse();
//            //    m.e = m.f = 0;
//            //    pt = pt.matrixTransform(m);
//            //    el.setAttribute(x, elementStart.x + pt.x);
//            //    el.setAttribute(y, elementStart.y + pt.y);
//            //    var dragEvent = document.createEvent("Event");
//            //    dragEvent.initEvent("dragged", true, true);
//            //    el.dispatchEvent(dragEvent);
//            //};
//            //document.body.addEventListener('mousemove', onmove, false);
//        }, false);
//        //document.body.addEventListener('mouseup', function () {
//        //    document.body.removeEventListener('mousemove', onmove, false);
//        //}, false);
//    })(a[i]);
//}

var start = function () {
    if (mouseButton != 1) {
        return;
    }
    // The start() is nothing but mousedown which gets executed on both drag and click events.
    siteDragged = false;
    //alert("start");

    //this.toFront();
    //el.parentNode.appendChild(el);

    site = this;

    this.ox = this.attr("cx");
    this.oy = this.attr("cy");
    //alert(this.attr("cx"));
    //this.animate({
    //    "fill-opacity": 2
    //}, 500);

    //currentSiteIndex = sitecoords.indexOf(this.ox + "," + this.oy);
    //currentSiteIndex2 = allsitecoords.indexOf(this.ox + "," + this.oy);


    //if (linkedSites.length == 0) {
    //    linkedSites = getAreaSitesBySite(this);
    //}

    var myInfo = getCurrentSiteInfo(this);
    this.siteInfo = myInfo[0];
    this.areaInfo = myInfo[1];

    //commented out the elasticity feature temporarily
    //if (markarea == true && continuousLine != undefined) {
    //    continuousLine.remove();
    //    continuousLine = null;
    //}
},

    progress = function (dx, dy) {
        if (mouseButton == 1) {
            siteDragged = true;
        }
        
        if ($(this.node).data('IsLymphNode')) {
            return;
        }
        //alert(siteDragged);

        DrawTooltip(this, 0);

        this.stop();
        //var att = { r: siteRadius };
        ////this.attr(att);
        //$(this.node).attr(att);

        this.toFront();

        if (isWithinRegions(this.ox + dx, this.oy + dy)) {
            mpx = this.ox + dx;
            mpy = this.oy + dy;

            var att = { r: siteRadius + 2 };
            $(this.node).attr(att);
            $(this.node).attr('class', 'site-Dragging');

            att = {
                cx: mpx,
                cy: mpy,
            };
            this.attr(att);

            var pA1, l1, pA2, l2;

            if (this.siteInfo != undefined) {
                pA1 = this.siteInfo["pathArray1"];
                l1 = this.siteInfo["line1"];
                pA2 = this.siteInfo["pathArray2"];
                l2 = this.siteInfo["line2"];

                //if (typeof areaId != 'undefined' && areaId > 0) {
                //    var areaElem = paper.getById(areaId);
                //    if (areaElem != null) {
                //        areaElem.toBack();
                //    }
                //}
                var myAreaRaphId;
                if (this.areaInfo != null && this.areaInfo != 'undefined') {
                    //if (typeof this.areaInfo.raphId != 'undefined' && this.areaInfo.raphId > 0) {
                    //    var areaElem = paper.getById(this.areaInfo.raphId);
                    //    if (areaElem != null) {
                    //        areaElem.toBack();
                    //    }
                    //}
                    myAreaRaphId = this.areaInfo.raphId;
                }
                else {
                    myAreaRaphId = areaId;
                }

                if (typeof myAreaRaphId != 'undefined' && myAreaRaphId > 0) {
                    var areaElem = paper.getById(myAreaRaphId);
                    if (areaElem != null) {
                        areaElem.remove();
                        if (this.areaInfo == null || this.areaInfo == 'undefined') {
                            areaId = 0;
                        }
                    }
                }

                if (typeof pA1 != 'undefined' && typeof l1 != 'undefined') {
                    if (pA1 != null && l1 != null) {
                        pA1[1][1] = mpx;
                        pA1[1][2] = mpy;
                        l1.attr({ path: pA1 });
                    }
                }

                if (typeof pA2 != 'undefined' && typeof l2 != 'undefined') {
                    if (pA2 != null && l2 != null) {
                        pA2[0][1] = mpx;
                        pA2[0][2] = mpy;
                        l2.attr({ path: pA2 });
                    }
                }
            }
        }
    },

    finish = function () {

        if (mouseButton != 1) {
            return;
        }
        //alert("up");
        //this.animate({
        //    "fill-opacity": 0
        //}, 500);

        //var att = {
        //    fill: "red"
        //};
        //this.attr(att);
        //$(this.node).addClass("site-Anterior");
        //$(this.node).attr('class', 'site-Anterior');

        //alert(1);
        SetSiteStyle($(this.node));

        //SetSiteStyle(this);

        //these coordinates can be undefined at times when the site is not dragged but only clicked
        //which results in start and finish to be fired but not progress
        if (mpx != undefined && mpy != undefined) {
            //sitecoords[currentSiteIndex] = mpx + "," + mpy;
            //allsitecoords[currentSiteIndex2] = mpx + "," + mpy;

            var regionDetails = GetRegion(mpx, mpy);
            var regId = regionDetails.split(";")[0];
            var reg = regionDetails.split(";")[1];

            $(this.node).data('Coordinates', mpx + "," + mpy);
            $(this.node).data('RegionId', regId);
            $(this.node).data('Region', reg);

            mpx = null;
            mpy = null;
        }
        //alert(siteDragged);

        if (siteDragged) {
            //this.toFront();
            var areaClosed = false;
            // Invoke this for areas only but not for independent sites.
            // FYI, for independent sites, both the areaInfo and siteInfo are returned as nulls.
            if (this.areaInfo != null) {
                areaClosed = isCloseEnough(this.areaInfo.areaNum);
            }
            else if (this.siteInfo != null) {
                areaClosed = isCloseEnough();
            }

            //$(this.node).data('is3D', false);
            //$(site.node).data('is3D', false);
            //$([this.node]).AddSiteMenu({
            //    menu: 'AddSiteMenu',
            //    onShow: onAddSiteMenuShow,
            //    onSelect: onAddSiteMenuItemSelect
            //});

            //if (e.button != 0) { return; }

            //if (is3D && $(this.node).data('AreaNo') == 0) {
            //    $([this.node]).DragSiteMenu({
            //        menu: 'AddSiteMenu',
            //        //menu:  (e.button == 0 ? 'AddSiteMenu' : 'SiteClickMenu') ,
            //        onSelect: onAddSiteMenuItemSelect
            //    });
            //} else {
            //UpdateSite($(this.node));
            //}

            $(this.node).data('is3D', is3D);

            //var sPosition = ($(this.node).data('AntPos') == 'Both / Either') ? "BothOrEither" : $(this.node).data('AntPos');
            var sPositionAssigned = ($(this.node).data('PositionAssigned') == undefined) ? false : $(this.node).data('PositionAssigned');
            if (is3D && $(this.node).data('AreaNo') == 0 && !sPositionAssigned) {
                //UpdateSite($(this.node));
                $(this.node).data('AntPos', 'undefined');
                $([this.node]).DragSiteMenu({
                    menu: 'AddSiteMenu',
                    onShow: onAddSiteMenuShow,
                    onSelect: onAddSiteMenuItemSelect
                });
            } else {
                UpdateSite($(this.node));
            }

            siteDragged = false;

            disableTitlePopup = true;

            //$([this.node]).SiteContextMenu({
            //    menu: 'SiteClickMenu',
            //    onShow: onSiteContextMenuShow,
            //    onSelect: onSiteContextMenuItemSelect
            //});
            //$(this.node).data('is3D', false);
            //$(".contextMenu").show();

            //$([this.node]).SiteContextMenu({
            //    menu: 'SiteClickMenu',
            //    onSelect: onSiteContextMenuItemSelect
            //});

            //UpdateSite($(this.node));

            //commented out the elasticity feature temporarily
            ////only for newly drawn (open) area, redraw the elastic line
            //if (markarea == true && linkedSites != undefined && !areaClosed) {
            //    var lastsitex = +$(linkedSites[linkedSites.length - 1].siteElement.node).data("Coordinates").split(",")[0];
            //    var lastsitey = +$(linkedSites[linkedSites.length - 1].siteElement.node).data("Coordinates").split(",")[1];
            //    DrawContinuousLine(lastsitex, lastsitey);
            //}
        }
    };

function SetProcolSiteStyle(site) {
    var att = {
        fill: "pink"
    };
    site.attr(att);

    $(site).SiteContextMenu({
        menu: 'ProtocolSiteClickMenu',
        onShow: onProtocolSiteContextMenuShow
    });

}

function SetLymphNodeSiteStyle(site) {
    $(site).SiteContextMenu({
        menu: 'LymphNodeSiteClickMenu',
        onSelect: onLymphNodeSiteContextMenuItemSelect
    });
}

function SetSiteStyle(site) {
    var antpos = site.data('AntPos');
    
    switch (antpos) {
        case "Anterior":
            site.attr('class', 'site-Anterior');
            var att = {
                //fill: "pink",
                r: siteRadius
            };
            site.attr(att);
            break;
        case "Posterior":
            //jsite.addClass("site-Posterior");
            //jsite.attr('class', 'site-Posterior');
            site.attr('class', 'site-Posterior');
            var att = {
                //fill: "black",
                r: siteRadius
            };
            site.attr(att);
            break;
        case "Both / Either":
        case "BothOrEither":
            //jsite.addClass("site-BothOrEither");
            //jsite.attr('class', 'site-BothOrEither');
            site.attr('class', 'site-BothOrEither');
            var att = {
                //fill: "red",
                r: siteRadius
            };
            site.attr(att);
            break;
    }


    var poa = site.data('PartOfArea');
    if (poa != undefined && poa == true) {
        var att = {
            fill: "blue",
            r: siteRadius / 2
        };
        site.attr(att);
    }

    //alert(s.data('AntPos'));
}

function drawMiniCanvas(aid) {
    ClearRegions();
    var p1 = new Raphael(document.getElementById('tempDiv'), diagramWidth, diagramHeight);
    var d1 = p1.image(rawImgURL, 0, 0, diagramWidth, diagramHeight);
    var reg1 = $.parseJSON(regionPaths);
    var resectedRegions = getResectedRegions(aid);

    $.each(reg1, function (key, item) {
        var thisPath = p1.path(item.Path);
        if ($.inArray(item.Region, resectedRegions) > -1) {
            thisPath.attr({ "stroke-width": "0", "fill": "#F7C3C6" });
        }
        thisPath.data({ "id": item.Region });
    });

    return p1.toSVG();
}

function loadResection() {
    var reg1 = $.parseJSON(regionPaths);
    var resectedRegions = getSelectedRegions(resectedColonSet);
    $.each(reg1, function (key, item) {
        var thisPath = paper.path(item.Path);
        if ($.inArray(item.Region, resectedRegions) > -1) {
            thisPath.attr({ "stroke-width": "0", "fill": "#F7C3C6" });
        }
        else {
            thisPath.attr({ "stroke-width": "0", "stroke": "white" });
        }
        thisPath.toBack();
        thisPath.data({ "id": item.Region });
        regions.push(thisPath);
    });
}

function fillResection() {
    ClearRegions();
    var reg1 = $.parseJSON(regionPaths);
    var resectedRegions = getSelectedRegions(resectedColonSet)
    $.each(reg1, function (key, item) {
        var thisPath = paper.path(item.Path);
        if ($.inArray(item.Region, resectedRegions) > -1) {
            thisPath.attr({ "stroke-width": "0", "fill": "#F7C3C6", "fill-opacity": "0.8" });
        }
        else {
            thisPath.attr({ "stroke-width": "0", "stroke": "black" });
        }
        thisPath.toBack();
        thisPath.data({ "id": item.Region });
        regions.push(thisPath);
    });
}

function getSelectedRegions(resectedColons) {
    var resectedRegions = [];
    var regs = $.parseJSON(resectionColonRegions);
    for (var i = 0; i < regs.length; i++) {
        if (resectedColons.has(regs[i].ResectedColonID)) {
            resectedRegions.push(regs[i].Region);
        }
    }
    return resectedRegions;
}

function getHighlightedColon(resectedColons) {
    //if (resectedColons.size <= 1 && resectedColons.values().next().value == 0) return;
    for (var value of resectedColons) {
        var element = $("img[value='" + value + "']");
        element.addClass('selectedimg');
        element.parent().siblings(".txtResectedColons").addClass('txtResectedColonsHighlighted');
        element.closest(".bgResectedColons").addClass('bgResectedColonsHighlighted');
    }
}

function getResectedRegions(aid) {
    var resectedRegions = [];
    var regs = $.parseJSON(resectionColonRegions);
    for (var i = 0; i < regs.length; i++) {
        if (regs[i].ResectedColonID == aid) {
            resectedRegions.push(regs[i].Region);
        }
    }
    return resectedRegions;
}