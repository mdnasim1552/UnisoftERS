var siteRadius = 15;
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

var linkedSites = [];
//var jsonsite;
//var currentSiteIndex;
//var currentSiteIndex2;
var mpx, mpy;

var areaId;
//var areaClosed;
var activeSite;
var activeSiteAnim = Raphael.animation({ r: 8 }, 100, "elastic");
var siteDragged = false;
//var areaPath;

var regions = [];
var regionsExist = false;

//var selectedProcType;
var diagram;
var arNo = 0;
var areas = [];
var diagramHeight = 0;
var diagramWidth = 0;

var docURL = document.URL;
var popup;

function LoadBasics(src, diagramDivID) {
    if (forPrinting == "True") {
        paper = new Raphael(document.getElementById("mydiagramDiv"), diagramWidth, diagramHeight);
    } else {
        paper = new Raphael(document.getElementById("DiagramDiv"), diagramWidth, diagramHeight);
    }
    if (paper != null) {
       // if (forPrinting != "True") { paper.remove();}       
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
    siteRadius = 9;
    //siteRadius = (siteRadius / 500) * ((Number(diagramHeight) + Number(diagramWidth)) / 2);
    //alert(document.getElementById("DiagramDiv"));

   

    //paper = new Raphael(document.getElementById("DiagramDiv"), diagramWidth, diagramHeight);

    //selectedProcType = $('#DiagramDropDownList').val();
    //var imageurl;

    //if (forPrinting == "True") {
    //    if (selectedProcType == "1") {
    //        imageurl = "../Images/Stomach.png";
    //    }
    //    else if (selectedProcType == "2") {
    //        imageurl = "../Images/ERCP.png";
    //    }
    //    else if (selectedProcType == "3" || selectedProcType == "4" || selectedProcType == "5") {
    //        imageurl = "../Images/Colon.png";
    //    }
    //    else {
    //        return;
    //    }
    //}
    //else {
    var bgPath = "";
    if (forPrinting == "True") {
      //  bgPath = "../";
    }

    //if (selectedProcType == "1" || selectedProcType == "5") {
    //    imageurl = bgPath + "../Images/stomach5.svg";
    //}
    //else if (selectedProcType == "2" || selectedProcType == "6") {
    //    imageurl = bgPath + "../Images/ercp-black.svg";
    //}
    //else if (selectedProcType == "3" || selectedProcType == "4" || selectedProcType == "12") {
    //    imageurl = bgPath + "../Images/colon-black.svg";
    //}
    //else if (selectedProcType == "8") {
    //    if (diagramId == "1") {
    //        imageurl = "../Images/brt-1-a.svg";
    //    }
    //    else if (diagramId == "2") {
    //        imageurl = "../Images/brt-2-a.svg";
    //    }
    //}
    //else {
    //    return;
    //}
      
    //}
    

   // $("[id$='DiagramImage']").attr("src", imageurl);
    //document.getElementById('DiagramImage').setAttribute('src', imageurl);

    diagram = paper.image(imageUrl, 0, 0, diagramWidth, diagramHeight)
    
    if (forPrinting != "True")
    {
        recalculateViewBox(paper);
    }

    fillResection();
    //paper.setViewBox(0, 0, diagramWidth, diagramHeight, true);
    //paper.setSize('100%', '100%');
};

function recalculateViewBox(canvas) {
    var max_x = 0, max_y = 0;
    canvas.forEach(function (el) {
        var box = el.getBBox();
        max_x = Math.max(max_x, box.x2);
        max_y = Math.max(max_y, box.y2);
    });
    if (max_x && max_y) { 
        canvas.setViewBox(0, 0, max_x, max_y);
        canvas.setSize('100%', '100%');
    }
}

function PlantSite(x, y, region, position) {
    id = id + 1;
    var site = paper.circle(x, y, siteRadius)
            .attr({
                fill: "white", "stroke-width": "2"
            });
    var outerSite = paper.circle(x, y, siteRadius + 1)
            .attr({
                stroke: "#4D4D4D"
            });

    $(site.node).data('Coordinates', x + "," + y);

    if (region != undefined) {
        $(site.node).data('Region', region);
    }

    if (position != undefined) {
        $(site.node).data('AntPos', position);
    }

    if ($(site.node).data('IsProtocol') == true) {
        //change colour
        //disable right click options other than add photo
        SetProcolSiteStyle($(site.node));
    }
    else {
        SetSiteStyle($(site.node));
    }

    

    //$([site.node]).SiteContextMenu({
    //    menu: 'SiteClickMenu',
    //    onShow: onSiteContextMenuShow,
    //    onSelect: onSiteContextMenuItemSelect
    //});

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

    if (show == 0) {
        if (popup) {
            popup.remove();
            popup_txt.remove();
            transparent_txt.remove();
        }
        return;
    }

    if (txt == undefined) { return; }

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

        linkedSites[linkedSites.length - 2].line2 = line;
        linkedSites[linkedSites.length - 2].pathArray2 = line.attr("path");

        linkedSites[linkedSites.length - 1].line1 = line;
        linkedSites[linkedSites.length - 1].pathArray1 = line.attr("path");

        if (linkedSites.length >= 3) {
            isCloseEnough();
        }
    }

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
    var independentSites = [];
    var textSiteTitle = [];
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
            var thisSiteRadius = siteRadius;
            if (this.SiteTitle.trim() == '') {
                siteRadius = 1;
            } else {
                var text = paper.text(this.XCoordinate, this.YCoordinate, this.SiteTitle.toLowerCase());
                text.attr({ 'font-size': 14, "font-weight": "bold" });
                textSiteTitle.push(text);
            }

            var site = PlantSite(this.XCoordinate, this.YCoordinate, this.Region, this.AntPos);
            siteRadius = thisSiteRadius;
            
            $(site.node).data('SiteId', this.SiteId);
            $(site.node).data('AreaNo', this.AreaNo);
            $(site.node).data('SiteTitle', this.SiteTitle);
            $(site.node).data('IsProtocol', this.IsProtocol);
            // alert(this.SiteTitle);
            //site.hover(function () {
            //    DrawTooltip(this, 1);
            //},
            //    function () {
            //        DrawTooltip(this, 0);
            //    });

            if (this.AreaNo == 0) {
                //independentSites.push(site);
            }
            else {
                if (this.SiteTitle != "") {
                    independentSites.push(site);
                }
                PopulateLinkedSites(site);
                DrawLine(this.XCoordinate, this.YCoordinate, site);
                site.toFront();
            }

           

        });

        //Move each first site (for area only) to front
        independentSites.forEach(function (site) {
            site.toFront();
        });

        //Move text (siteTitle) to front
        textSiteTitle.forEach(function (txtSite) {
            txtSite.toFront();
        });

        //if (an != 0) {
        //    arNo = an;
        //    var a = {
        //        areaNum: arNo,
        //        areaSites: linkedSites,
        //        raphId: areaId
        //    }
        //    areas.push(a);
        //}

        


    });

//if (selectedProcType === "1" || selectedProcType === "3            ") {
            LoadProtocolSiteNodes();
        //}
    //if (forPrinting == "True") { return paper.toSVG(); }
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

        //$([thisNode.node]).SiteContextMenu({
        //    menu: 'ProtocolSiteClickMenu',
        //    onShow: onProtocolSiteContextMenuShow
        //});
    }
}

function ReturnSvgXml(sReportImageUrl) {

    if (paper != undefined) {

        paper.image(sReportImageUrl, 0, 0, diagramWidth, diagramHeight).toBack();

        //if (selectedProcType == "1") {
        //    paper.image(imageUrl.replace("stomach5.svg", "Stomach.png"), 0, 0, diagramWidth, diagramHeight).toBack();

        //}
        //else if (selectedProcType == "2" || selectedProcType == "6") {
        //    paper.image(imageUrl.replace("ercp-black.svg", "ERCP.png"), 0, 0, diagramWidth, diagramHeight).toBack();

        //}
        //else if (selectedProcType == "3" || selectedProcType == "4" || selectedProcType == "5") {
        //    paper.image(imageUrl.replace("colon-black.svg", "Colon.png"), 0, 0, diagramWidth, diagramHeight).toBack();

        //}
        //else if (selectedProcType == "8") {
        //    paper.image(imageUrl.replace("enteroscopy_ante_red.svg", "enteroscopy_ante.png"), 0, 0, diagramWidth, diagramHeight).toBack();

        //}
        //else if (selectedProcType == "9") {
        //    paper.image(imageUrl.replace("enteroscopy_retro.svg", "enteroscopy_retro.png"), 0, 0, diagramWidth, diagramHeight).toBack();

        //}
        //else {

        //}

        return paper.toSVG();
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


var currentSite;

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


function ReMarkArea(affectedArea, deletedIndex) {

    var prev, next;
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

}

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

        regions.push(thisPath);
    }
    regionsExist = true;
    return false;
}

function GetRegion(x, y) {
    //var regionData = getRegionData();
    var regionData = $.parseJSON(regionPaths);
    var regionName = "";
    for (i = 0; i < regionData.length; i++) {
        var isinside = Raphael.isPointInsidePath(regionData[i]["Path"], x, y);
        if (isinside) {
            regionName = regionData[i]["Region"];
        }
    }
    //$("#positionLabel").text(regionName);
    return regionName;
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
    //.click(function () {
    //    diagram.trigger('click', diagram);
    //});

    $(area.node).attr({'class': 'area-marked'});
    //areaId = area.node.raphaelid;

    //Bring the sites to the front
    //sitesCollection.forEach(function (site) {
    //    //alert(0);

    //    var elem = site["siteElement"];
    //    //elem.toFront();
    //    //elem.node.parentNode.appendChild(elem.node);
    //    //elem.click(function () { alert("yoyo") });
    //    //elem.node.toFront();
    //    //alert(elem.node);
    //});

    //independentSites.forEach(function (site) {
    //   // var isinside = Raphael.isPointInsidePath(compath, $(site.node).data('Coordinates').split(",")[0], $(site.node).data('Coordinates').split(",")[1]);
    //    //if (isinside) {
    //    site.toFront();
    //    //}
    //});

    //sitesCollection[0]["siteElement"].toFront();

    //var gogo = paper.getById(sitesCollection[0]["siteElement"].node.raphaelid);
    //gogo.toFront();

    return area.node.raphaelid;
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
            areaId = 0;
        }
    }

    //create a new shaded area when the first and last sites are close enough
    var diffx, diffy;
    if (mySites.length >= 3) {
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

}

$(document).ready(function () {

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
        //$("#confirmDiv").dialog();
        if (activeSite) {
            //if (confirm('Are you sure you want to remove this site and all associated data if any?')) {
            //    DeleteSite($(activeSite.node));
            //}
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

function SetProcolSiteStyle(site) {
    var att = {
        fill: "pink"
    };
    site.attr(att);
    site.attr('class', 'site-Protocol');
    

}


function SetSiteStyle(site) {
    var antpos = site.data('AntPos');
    //alert(siteRadius);
    switch (antpos) {
        case "Anterior":
            //alert(0)
            //jsite.parent().addClass("site-Anterior");
            //jsite.addClass("site-Anterior");
            site.attr('class', 'site-Anterior-Rpt');
            var att = {
                //fill: "pink",
                r: siteRadius
            };
            site.attr(att);
            break;
        case "Posterior":
            //jsite.addClass("site-Posterior");
            //jsite.attr('class', 'site-Posterior');
            site.attr('class', 'site-Posterior-Rpt');
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
            site.attr('class', 'site-BothOrEither-Rpt');
            var att = {
                //fill: "red",
                r: siteRadius
            };
            site.attr(att);
            break;
    }

    //alert(s.data('AntPos'));
}

function fillResection() {
    var reg1 = $.parseJSON(regionPaths);
    var resectedColons = new Set(resectionColonId.split(',').map(Number));
    var resectedRegions = getSelectedRegions(resectedColons)
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

function getResectionText() {
    var restxt = getResectionTxt(resectionColonId);
    if (restxt == '') {
        return '';
    } else {
        return '<b><font color="#0072c6">Resected Colon: </font></b>' + restxt;
    }
   
}

function getResectionTexts() {
    var restxt = getResectionTxt(resectionColonId);
        return  restxt;   
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
