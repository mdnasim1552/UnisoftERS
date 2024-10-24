var siteRadius = 5;
var addsite = false;
var markarea = false;
//var sitecoords = [];
//var allsitecoords = [];
var site;

var paper;

//var line1;
//var line2;
//var lines = [];
//var pathArrays = [];

//var pathArray1;
//var pathArray2;
var id = 0;

var independentSites = [];
var linkedSites = [];
//var jsonsite;
//var currentSiteIndex;
//var currentSiteIndex2;
var mpx, mpy;

var areaId;
//var areaClosed;
var activeSite;
var activeSiteAnim = Raphael.animation({ r: 8 }, 1000, "elastic");
var siteDragged = false;
//var areaPath;

var regions = [];
var regionsExist = false;

//var selectedProcType;
var diagram;
var arNo = 0;
var areas = [];
//var diagramHeight = 0;
//var diagramWidth = 0;

var docURL = document.URL;
var popup;

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
    }

    //diagramHeight = $('#HeightTextBox').val();
    //diagramWidth = $('#WidthTextBox').val();
    //diagramHeight = 400;
    //diagramWidth = 350;
    siteRadius = 5;
    siteRadius = (siteRadius / 500) * ((Number(diagramHeight) + Number(diagramWidth)) / 2);

    paper = new Raphael(document.getElementById('DiagramDiv'), diagramWidth, diagramHeight);

    //selectedProcType = $('#DiagramDropDownList').val();
    //selectedProcType = 1;
    var imageurl;

    if (selectedProcType == "1") {
        imageurl = "../../Images/stomach5.svg";
    }
    else if (selectedProcType == "2") {
        imageurl = "../../Images/ercp-black.svg";
    }
    else if (selectedProcType == "3" || selectedProcType == "4" || selectedProcType == "5") {
        imageurl = "../../Images/colon-black.svg";
    }
    else {
        return;
    }

    diagram = paper.image(imageurl, 0, 0, diagramWidth, diagramHeight)

    .mousemove(function (event) {
        //var posx = event.clientX - ($(document).scrollLeft() + $('#DiagramDiv').offset().left);
        //var posy = event.clientY - ($(document).scrollTop() + $('#DiagramDiv').offset().top);
        var posx = event.pageX - ($('#DiagramDiv').offset().left);
        var posy = event.pageY - ($('#DiagramDiv').offset().top);
        $("#CoordLabel").text(posx + "," + posy);
        //$("#CoordLabel").text(posx + "," + posy + " A " + event.clientX + "," + event.clientY + " B " + event.pageX + "," + event.pageY + " C " + $('#DiagramDiv').offset().left + "," + $('#DiagramDiv').offset().top);
        var reg = GetRegion(posx, posy);
        $("#" + positionLabelClientId).text(reg);
        if (addsite == true || markarea == true) {
            if (reg != "") {
                $('#DiagramDiv').css('cursor', 'crosshair');
            }
            else {
                $('#DiagramDiv').css('cursor', 'default');
            }
        }
    })

    .click(function () {
        //alert(0)
        if (addsite == true || markarea == true) {

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

            var reg = GetRegion(mx, my);
            //$(site.node).data('Region', reg);
            //$(site.node).data('Coordinates', mx + "," + my);

            site = PlantSite(mx, my, reg);

            //allsitecoords.push(mx + "," + my);

            //determinePosition(my);

            if (addsite == true) {
                $(site.node).data('AreaNo', 0);

                independentSites.push(site);

                $([site.node]).AddSiteMenu({
                    menu: 'AddSiteMenu',
                    onShow: onAddSiteMenuShow,
                    onSelect: onAddSiteMenuItemSelect
                });
                addsite = false;
            }
            else if (markarea == true) {
                $(site.node).data('AntPos', 'Both / Either');
                $(site.node).data('AreaNo', arNo);

                PopulateLinkedSites(site);
                SetSiteStyle($(site.node));
                InsertSite($(site.node));
                DrawLine(mx, my, site);
            }
        }
    })

    //paper.setViewBox(0, 0, diagramWidth, diagramHeight, true);
    //paper.setSize('40%', '40%');

};

function PlantSite(x, y, region, position) {

    id = id + 1;

    var site = paper.circle(x, y, siteRadius)
            .attr({
                fill: "white",
                cursor: "pointer"
            })

            .click(function () {
                //alert(1);
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
                        //SetSiteStyle($(activeSite.node));
                        var att = { r: siteRadius };
                        activeSite.attr(att);
                        activeSite = null;
                    }
                    activeSite = this;
                    //this.toFront();
                    var anim = Raphael.animation({ r: 8 }, 1000, "elastic");
                    //alert(1);
                    this.animate(anim.repeat(Infinity));

                    // setTimeout in this case is used like thread yielding in this case. 
                    // Without this, the animation.stop runs immediately after the animation is set. So no effect on the front end.
                    // Use of setTimeout makes sure the current code is executed before the new code gets executed.
                    setTimeout(function () {
                        $(document).click(function () {
                            if (activeSite) {
                                //alert(0);
                                activeSite.stop();
                                //SetSiteStyle($(activeSite.node));
                                var att = { r: siteRadius };
                                activeSite.attr(att);
                                activeSite = null;
                            }
                        });
                    }, 0);
                }
            })

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
    
    $(site.node).data('Coordinates', x + "," + y);

    if (region != undefined) {
        $(site.node).data('Region', region);
    }

    if (position != undefined) {
        $(site.node).data('AntPos', position);
    }

    SetSiteStyle($(site.node));

    //$([site.node]).SiteContextMenu({
    //    menu: 'SiteClickMenu',
    //    onShow: onSiteContextMenuShow,
    //    onSelect: onSiteContextMenuItemSelect
    //});

    return site;
}

function DrawTooltip(object, show) {
    //alert(text);
    //debugger;
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

    if (show == 0) {
        if (popup) {
            popup.remove();
            popup_txt.remove();
            transparent_txt.remove();
        }
        return;
   }

    if (txt == undefined || txt == "") { return; }
    txt = "Site " + txt;
    //draw text somewhere to get its dimensions and make it transparent
    transparent_txt = paper.text(100, 100, txt).attr({ fill: "transparent" });

    //get text dimensions to obtain tooltip dimensions
    var txt_box = transparent_txt.getBBox();

    //draw text
    popup_txt = paper.text(x + txt_box.width, y - txt_box.height - 9, txt).attr({ fill: "black", font: "20px sans-serif" });

    var bb = popup_txt.getBBox();

    //draw path for tooltip box
    popup = paper.path(
					// 'M'ove to the 'dent' in the bubble
					"M" + (x) + " " + (y - 4) +
					// 'v'ertically draw a line 5 pixels more than the height of the text
					"v" + -(bb.height + 5) +
					// 'h'orizontally draw a line 10 more than the text's width
					"h" + (bb.width + 10) +
					// 'v'ertically draw a line to the bottom of the text
					"v" + bb.height +
					// 'h'orizontally draw a line so we're 5 pixels fro thge left side
					"h" + -(bb.width + 5) +
					// 'Z' closes the figure
					"Z").attr({ fill: "#CADDF5" });

    //finally put the text in front
    popup_txt.toFront();
}

function PopulateLinkedSites(site)
{
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
    //debugger;
    var line;
    //id = id + 1;
    //alert(id);

    //sitecoords.push(mx + "," + my);
    //sitecoords.push(x + "," + y);

    //if (sitecoords.length > 1 && markarea == true) {
    if (linkedSites.length >= 2) {
        //line = paper.path("M" + sitecoords[sitecoords.length - 2] + " L" + sitecoords[sitecoords.length - 1]);
        var prevSiteCoordinates = $(linkedSites[linkedSites.length - 2].siteElement.node).data("Coordinates");
        line = paper.path("M" + prevSiteCoordinates + " L" + x + "," + y);
        
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

        if (linkedSites.length >= 3) {
            isCloseEnough();
        }
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
        //debugger;
        if (($.inArray(this.AreaNo, areaNos)) == -1) {
            areaNos.push(this.AreaNo);
        }
    });
    
    $(areaNos).each(function () {
        //debugger;
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
            var site = PlantSite(this.XCoordinate, this.YCoordinate, this.Region, this.AntPos);

            $(site.node).data('SiteId', this.SiteId);
            $(site.node).data('AreaNo', this.AreaNo);
            $(site.node).data('SiteTitle', this.SiteTitle);

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
                DrawLine(this.XCoordinate, this.YCoordinate, site);
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
        
        //debugger;
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
    var reg = site.data('Region');
    var xy = site.data('Coordinates');
    var x = xy.split(",")[0];
    var y = xy.split(",")[1];
    var an = site.data('AreaNo');

    currentSite = site;
    
    var jsondata =
    {
        procId: procedureId,
        region: reg,
        xCd: x,
        yCd: y,
        position: antpos,
        areaNumber: an,
        height: diagramHeight,
        width: diagramWidth
    };

    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/InsertSite",
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: InsertSiteComplete,
        error: function (jqXHR, textStatus, data) {
            //var vars = jqXHR.responseText.split("&"); 
            //alert(vars[0]); 
            alert("Unknown error occured while saving the site to the database. Please contact Unisoft helpdesk.");
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

        //var xy = currentSite.data('Coordinates');
        //var x = xy.split(",")[0];
        //var y = xy.split(",")[1];

        currentSite.hover(function () {
            //debugger;
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
    }
}

function UpdateSite(site) {
    var id = site.data('SiteId');
    var antpos = (site.data('AntPos') == 'Both / Either') ? " BothOrEither" : site.data('AntPos');
    var reg = site.data('Region');
    var xy = site.data('Coordinates');
    var x = xy.split(",")[0];
    var y = xy.split(",")[1];

    currentSite = site;

    var jsondata =
    {
        siteId: id,
        region: reg,
        xCd: x,
        yCd: y,
        position: antpos
    };

    //alert(JSON.stringify(jsondata));     
    //url: webserviceUrl + '/UpdateSite',

    $.ajax({
        type: "POST",
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/UpdateSite",
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: UpdateSiteComplete,
        error: function (jqXHR, textStatus, data) {
            //var vars = jqXHR.responseText.split("&"); 
            //alert(vars[0]); 
            alert("Unknown error occured while saving the site to the database. Please contact Unisoft helpdesk.");
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
    }
}

function ShowError(headermsg, errorref) {
    var errorMsg = "<table>"
    errorMsg = errorMsg + "<tr><td colspan='2' class='aspxValidationSummaryHeader'>" + headermsg + "</td></tr>"
    errorMsg = errorMsg + "<tr><td><br/></td></tr>"
    errorMsg = errorMsg + "<tr><td colspan='2'>Please contact Unisoft Helpdesk with the following details.</td></tr>"
    errorMsg = errorMsg + "<tr><td style='width:100px'>Error Reference:</td><td>" + errorref + "</td></tr>"
    errorMsg = errorMsg + "<tr><td>Procedure Id:</td><td>" + procedureId + "</td></tr>"
    errorMsg = errorMsg + "</table>"
    ShowErrorNotification(errorMsg);
}

function DeleteSite(site) {
    if (confirm('Are you sure you want to remove this site and all associated data if any?')) {
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
                alert("Unknown error occured while deleting the site from the database. Please contact Unisoft helpdesk.");
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
        //var deletedAreaNo = site.data('AreaNo');
        var l1, l2;
        var index;
        var mySites, myRaphId;

        var myInfo = getCurrentSiteInfo(paper.getById(site[0].raphaelid));
        this.siteInfo = myInfo[0];
        this.areaInfo = myInfo[1];
        //debugger;
        if (this.areaInfo != null && this.areaInfo != 'undefined') {
            mySites = this.areaInfo.areaSites;
            myRaphId = this.areaInfo.raphId;

            //for (var i = 0; i < this.areaInfo.areaSites.length; i++) {
            //    if (this.areaInfo.areaSites[i].siteElement == (paper.getById(site[0].raphaelid))) {
            //        index = i;
            //        break;
            //    }
            //}
            //if (index > -1) {
            //    this.areaInfo.areaSites.splice(index, 1);
            //}
            //if (typeof this.areaInfo.raphId != 'undefined' && this.areaInfo.raphId > 0) {
            //    var areaElem = paper.getById(this.areaInfo.raphId);
            //    if (areaElem != null) {
            //        areaElem.remove();
            //    }
            //}
        }
        else {
            mySites = linkedSites;
            myRaphId = areaId;
            //for (var i = 0; i < linkedSites.length; i++) {
            //    if (linkedSites[i].siteElement == (paper.getById(site[0].raphaelid))) {
            //        index = i;
            //        break;
            //    }
            //}
            //if (index > -1) {
            //    linkedSites.splice(index, 1);
            //}
            //if (typeof areaId != 'undefined' && areaId > 0) {
            //    var areaElem = paper.getById(areaId);
            //    if (areaElem != null) {
            //        areaElem.remove();
            //    }
            //}
        }

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
        RefreshSiteSummary();
    }
}

function ReMarkArea(affectedArea, deletedIndex) {
    //debugger;
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
        thisPath.attr({ "stroke-width": "1", "stroke":"red" });
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
    for (i = 0; i < regionData.length; i++) {
        var isinside = Raphael.isPointInsidePath(regionData[i]["Path"], x, y);
        if (isinside)
        {
            regionName = regionData[i]["Region"];
        }
    }
    //$("#positionLabel").text(regionName);
    return regionName;
}

function isWithinRegions(x, y)
{
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

function ClearRegions()
{
    regions.forEach(function (reg) {
        reg.remove();
    });
    regionsExist = false;
}

function getCurrentSiteInfo(val) {
    //debugger;
    //for (var i in linkedSites) {
    //    alert(linkedSites[key]);
    //    if (i == key && linkedSites[key] === val) {
            
    //        return linkedSites[i];
    //    }
    //}
    //var arrayOfObjects = [{ "id": 28, "Title": "Sweden" }, { "id": 56, "Title": "USA" }, { "id": 89, "Title": "England" }];
    //debugger;

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
    //    //debugger;
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
        //debugger;
        var elem = site["siteElement"];
        elem.toFront();
        //elem.node.parentNode.appendChild(elem.node);
        //elem.click(function () { alert("yoyo") });
        //elem.node.toFront();
        //alert(elem.node);
    });
    
    independentSites.forEach(function (site) {
        var isinside = Raphael.isPointInsidePath(compath, $(site.node).data('Coordinates').split(",")[0], $(site.node).data('Coordinates').split(",")[1]);
        if (isinside) {
            site.toFront();
        }
    });

    //sitesCollection[0]["siteElement"].toFront();
    //debugger;
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
    //    //debugger;
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
    //debugger;
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
            areaId = 0;
        }
    }

    //create a new shaded area when the first and last sites are close enough
    var diffx, diffy;
    if (mySites.length >= 3) {
        //diffx = mySites[0].siteCoord.split(",")[0] - mySites[mySites.length - 1].siteCoord.split(",")[0];
        //diffy = mySites[0].siteCoord.split(",")[1] - mySites[mySites.length - 1].siteCoord.split(",")[1];
        diffx = $(mySites[0].siteElement.node).data("Coordinates").split(",")[0] - $(mySites[mySites.length - 1].siteElement.node).data("Coordinates").split(",")[0];
        diffy = $(mySites[0].siteElement.node).data("Coordinates").split(",")[1] - $(mySites[mySites.length - 1].siteElement.node).data("Coordinates").split(",")[1];

        if ((diffx >= -10 && diffx <= 10) && (diffy >= -10 && diffy <= 10)) {
            myAreaRaphId = shadearea(mySites);
            if (indexFound > -1) {
                areas[indexFound]["raphId"] = myAreaRaphId;
            }
            else {
                areaId = myAreaRaphId;
            }
            
        }
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
        addsite = true;
        event.preventDefault();
    });

    $("#ctl00_LeftPaneContentPlaceHolder_MarkAreaButton_input").click(function (event) {
        
        if ($(this).attr("value") == "Mark Area") {
            $find("ctl00_LeftPaneContentPlaceHolder_AddSiteButton").set_enabled(false);
            //btn.set_text("Done");
            $(this).prop('value', 'Done');
            markarea = true;
            addsite = false;

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
        }
        event.preventDefault();
    });

    $("#ctl00_LeftPaneContentPlaceHolder_RemoveSiteButton_input").click(function (event) {
        if (activeSite) {
            DeleteSite($(activeSite.node));
        }
        event.preventDefault();
    });

    $("#ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton_input").click(function (event) {
        if (regionsExist == false) {
            BuildRegions();
        }
        else {
            ClearRegions();
        }
        var btn = $find("ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton_input");
        event.preventDefault();
    });
});


function SetSiteStyle(site) {
    //alert(site.constructor.prototype == Raphael.el)
    //var gogo;
    //if (site.constructor.prototype == Raphael.el)
    //{
    //    gogo = site;
    //}
    //else
    //{
    //    //alert($(site.node));
    //    //alert($(site).raphaelid);
    //    //gogo = paper.getById(site.node.raphaelid);
    //}
    ////alert(gogo);

    //alert(site.data('AntPos'));
    //var jsite = $(site.node);
    //alert(site);
    var antpos = site.data('AntPos');
    //alert(antpos);
    switch (antpos) {
        case "Anterior":
            //alert(0)
            //jsite.parent().addClass("site-Anterior");
            //jsite.addClass("site-Anterior");
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

    //alert(s.data('AntPos'));
}

function getRegionData() {

    //var jsonString = [
    // {
    //     "Region": "Upper Oesophagus",
    //     "Path": "M 193,8, 247,8, 247,80, 193,80 z"
    // },
    //  {
    //      "Region": "Middle Oesophagus",
    //      "Path": "M 193,80, 247,80, 247,160, 193,160 z"
    //  },
    //  {
    //      "Region": "Lower Oesophagus",
    //      "Path": "M 193,160, 247,160, 247,218, 252,230, 200,244, 193,223 z"
    //  }
    //];

    var jsonString = [
        { "RegionPathId": 1, "Diagram": "Stomach", "Region": "Upper Oesophagus", "Path": "M 193, 8, L247, 8, L247, 80, L193, 80 z" },
        { "RegionPathId": 2, "Diagram": "Stomach", "Region": "Middle Oesophagus", "Path": "M 193, 80, 247, 80, 247, 160, 193, 160 z" },
        { "RegionPathId": 3, "Diagram": "Stomach", "Region": "Lower Oesophagus", "Path": "M 193,160, 247,160, 247,218, 252,230, 200,244, 193,223 z" }
    ]

    //var gogo = regionPaths;

    //var jsonString = "<%= RegionPathsJson%>";
    //alert(regionPaths);
    //alert(jsonString);

    //document.writeln(regionPaths);
    //document.writeln(jsonString);

    var gogo = $.parseJSON(regionPaths);
    //document.writeln(gogo);

    //return jsonString;
    
    return gogo;
}
