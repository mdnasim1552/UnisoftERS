<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/ProcedureMaster.Master" CodeBehind="Procedure.aspx.vb" Inherits="UnisoftERS.products_common_proceduresummary_aspx" %>

<%--<%@ Register TagPrefix="unisoft" TagName="diagram" Src="~/UserControls/diagram.ascx" %>--%>

<asp:Content ID="Content1" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="server">
    <link href="../Styles/contextmenu.css" rel="stylesheet" />
    <style type="text/css">
        #ctl00_ctl00_BodyContentPlaceHolder_pBodyContentPlaceHolder_ResectedColonWindow_C {
            height: calc(90vh - 120px) !important;
        }

        .highlight-border {
            border: 2px solid red; /* Or any color you prefer */
            transition: border 0.3s ease; /* Smooth transition */
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="server">

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            var docURL = document.URL;
            var webMethodLocation = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Default.aspx/";
            var showRegionsButtonClientId = '#<%=ShowRegionsButton.ClientID%>';
            var positionLabelClientId = '<%=PositionLabel.ClientID%>';

            function ShowErrorNotification(errorMessage) {
                var notification = $find("<%= ErrorNotification.ClientID%>");
                notification.set_text(errorMessage);
                notification.show();
            }

            function SetDiagramContextMenu() {
                //if (['2', '7'].indexOf(selectedProcType) < 0) { return; } //Display diagnoses menu for ERCP, EUS (HPB) only.

                $([diagram.node]).DiagramContextMenu({
                    menu: 'DiagramClickMenu',
                    onShow: onDiagramContextMenuShow,
                    onSelect: onDiagramContextMenuItemSelect

                });
            }

            function refreshDiagramGastritis(siteid) {
                var test = parent.location.href;
                test = test.replace("SiteId=-1", "SiteId=" + siteid);

                parent.location.href = test; //+ '&DefaultNav=yes'
            }

            function refreshParentWithDiagram() {
                <%--$(<%=RefreshDiagramButton.ClientID%>).click();--%>
                var ajaxManager = $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>");
                ajaxManager.ajaxRequest('refreshDiagram');
            }

            function RefreshSiteSummary() {
                $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest("content");
                if (currentSite != undefined)
                    SetTreeNode(currentSite.data('SiteId'));
                //SetPhotoContextMenu();
            }

            function showProcNotCarriedOutWindow() {
<%--            var oWnd = $find("<%= ProcNotCarriedOutRadWindow.ClientID%>");
                oWnd.set_title("Procedure NOT carried out");
                oWnd.show();--%>
            }

            function RemoveSiteClicked() {
                if (activeSite) {
                    DeleteSite($(activeSite.node));
                }
                event.preventDefault();
            }

            function ShowRegionsButtonClicked() {
                if (regionsExist == false) {
                    BuildRegions();
                }
                else {
                    fillResection();
                }
                var btn = $find("ctl00_LeftPaneContentPlaceHolder_ShowRegionsButton_input");
                event.preventDefault();
            }

            function MarkAreaClicked() {
                if ($find("<%=MarkAreaButton.ClientID%>").get_text() == "Mark Area") {
                    $find("<%=AddSiteButton.ClientID%>").set_enabled(false);
                    $find("<%=RemoveSiteButton.ClientID%>").set_enabled(false);
                    $find("<%=PhotosButton.ClientID%>").set_enabled(false);
                    $find("<%=ShowRegionsButton.ClientID%>").set_enabled(false);
                    if ($find("<%=ResectedColonButton.ClientID%>") != null) {
                        $find("<%=ResectedColonButton.ClientID%>").set_enabled(false);
                    }
<%--                        $find("<%=ByDistanceButton.ClientID%>").set_enabled(false);--%>
                    //btn.set_text("Done");
                    $find("<%=MarkAreaButton.ClientID%>").set_text('Done');
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
                    $find("<%=MarkAreaButton.ClientID%>").set_text('Mark Area');
                    $find("<%=AddSiteButton.ClientID%>").set_enabled(true);
                    $find("<%=RemoveSiteButton.ClientID%>").set_enabled(true);
                    $find("<%=PhotosButton.ClientID%>").set_enabled(true);
                    $find("<%=ShowRegionsButton.ClientID%>").set_enabled(true);
                    if ($find("<%=ResectedColonButton.ClientID%>") != null) {
                        $find("<%=ResectedColonButton.ClientID%>").set_enabled(true);
                    }
                        <%---$find("<%=ByDistanceButton.ClientID%>").set_enabled(true);--%>
                    $("#DiagramDiv").css("cursor", "default");
                }
                event.preventDefault();
                if (linkedSites.length != 0) {
                    SetTreeNode(currentSite.data('SiteId') - linkedSites.length + 1);
                }
            }

            $(document).ready(function () {
                newProcedureInitiated = true;

                if ($find("<%=ShowSitesByDiagramRadButton.ClientID%>") != null) {
                    $find("<%=ShowSitesByDiagramRadButton.ClientID%>").set_visible(false);

                    hideShowSummary(false);

                    SetDiagramContextMenu();
                    SetTreeNode(0);
                }

                $("#<%=AddSiteButton.ClientID%>").click(function (event) {
                    addsite = true;
                    event.preventDefault();
                });

                $("#IDBody").css("cursor", "progress");

                $("#<%=TransnasalCheckBox.ClientID%>").on("click", function () {
                    var obj = {};
                    obj.transnasal = $(this).is(":checked");

                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "UpdateTransnasalProcedure",
                        dataType: "json",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            //handle any errors
                        }

                    });
                });
                
                $("#<%=EUSCompleteCheckBox.ClientID%>").on("click", function () {
                    var obj = {};
                    obj.EUSSuccessful = $(this).is(":checked");

                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "UpdateEUSSuccess",
                        dataType: "json",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            //handle any errors
                        },
                        error: function (jqXHR, textStatus, data) {
                            alert(jqXHR.responseText);
                        }

                    });
                });



            });
            Sys.Application.add_load(function () {
                $("#<%=AddMandatorySitesCheckBox.ClientID%>").on("click", function () {
                    if ($(this).is(":checked")) {
                        var procedureTypeId =<%=ProcedureTypeId%>, procedureId =<%=procedure_Id%>, height =<%=DiagramHeight%>, width =<%=DiagramWidth%>;
                        if (procedureTypeId == 1) {
                            AddMandatorySite(procedureId, 1002, "152.8958330154419", "36.2430419921875", "BothOrEither", "0", height, width, false);//Upper Oesophagus
                            AddMandatorySite(procedureId, 1008, "153.11111068725586", "157.5", "BothOrEither", "0", height, width, false);//Lower Oesophagus
                            AddMandatorySite(procedureId, 1011, "258.11111068725586", "196.5", "BothOrEither", "0", height, width, false);//Fundus
                            AddMandatorySite(procedureId, 1018, "171.11111068725586", "293.5", "BothOrEither", "0", height, width, false);//Angulus
                            AddMandatorySite(procedureId, 1022, "143.11111068725586", "332.5", "BothOrEither", "0", height, width, false);//Antrum
                            AddMandatorySite(procedureId, 1013, "237.11111068725586", "241.5", "BothOrEither", "0", height, width, false);//Upper Body
                            //console.log(procedureId, 1002, "152.8958330154419", "36.2430419921875", "BothOrEither", "0", height, width, false);
                            //AddMandatorySite(procedureId, regionId, xCd, yCd, position, areaNumber, height, width, positionSpecified)
                            refreshParentWithDiagram();
                        }
                    } else {
                        //RefreshSiteSummary();
                        //RefreshSiteTitles();
                        //refreshParent();
                        refreshParentWithDiagram();
                    }
                 });
            });
            function AddMandatorySite(procedureId, regionId, xCd, yCd, position, areaNumber, height, width, positionSpecified) {
                var jsondata =
                {
                    procId: procedureId,
                    regionId: regionId,
                    xCd: xCd,
                    yCd: yCd,
                    position: position,
                    areaNumber: areaNumber,
                    height: height,
                    width: width,
                    positionSpecified: positionSpecified
                };

                $.ajax({
                    type: "POST",
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/UpdateSite.aspx/InsertSite",
                    timeout: 3000,
                    async: false,
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (jqXHR, textStatus, data) {

                    },
                    error: function (jqXHR, textStatus, data) {
                        //var vars = jqXHR.responseText.split("&"); 
                        //alert(vars[0]); 
                        alert("Unknown error occured while saving the site to the database. Please contact HD Clinical helpdesk.");
                        //LoadBasics();
                        //LoadExistingPatient();
                    }
                });
            }
            function DeleteMandatorySite() {
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
                        //DeleteSiteComplete(jqXHR, site);
                    },
                    error: function (jqXHR, textStatus, data) {
                        alert("Unknown error occured while deleting the site from the database. Please contact HD Clinical helpdesk.");
                        //LoadBasics();
                        //LoadExistingPatient();
                    }
                });
            }

            function SitesByDistance(sender, args) {
                var currentState = sender.get_selectedToggleState();
                if (currentState.get_text() == 'by Distance') {
                    showByDiagram();
                } else {
                    showByDistance();
                }
            }

            function showByDistance() {
                $('#DiagramDiv').hide();
                $('#PositionLabelDiv').hide();
                $('#SpacerDiagramDiv').hide();
                $('#ByDistanceDiv').show();

                if ($find("<%= ResectedColonButton.ClientID%>") != null)
                    $find("<%= ResectedColonButton.ClientID%>").set_enabled(false);

                if ($find("<%= AddSiteButton.ClientID%>") != null)
                    $find("<%= AddSiteButton.ClientID%>").set_enabled(false);

                if ($find("<%= MarkAreaButton.ClientID%>") != null)
                    $find("<%= MarkAreaButton.ClientID%>").set_enabled(false);

                if ($find("<%= RemoveSiteButton.ClientID%>") != null)
                    $find("<%= RemoveSiteButton.ClientID%>").set_enabled(false);

                if ($find("<%= PhotosButton.ClientID%>") != null)
                    $find("<%= PhotosButton.ClientID%>").set_enabled(false);

                if ($find("<%= ShowRegionsButton.ClientID%>") != null)
                    $find("<%= ShowRegionsButton.ClientID%>").set_enabled(false);

                if ($find("<%=ByDistanceButton.ClientID%>") != null)
                    $find("<%=ByDistanceButton.ClientID%>").set_visible(false);

                if ($find("<%=ShowSitesByDiagramRadButton.ClientID%>") != null)
                    $find("<%=ShowSitesByDiagramRadButton.ClientID%>").set_visible(true);
            }

            function showByDiagram() {
                $('#DiagramDiv').show();
                $('#PositionLabelDiv').show();
                $('#SpacerDiagramDiv').show();
                $('#ByDistanceDiv').hide();
                if ($find("<%= ResectedColonButton.ClientID%>") != null)
                    $find("<%= ResectedColonButton.ClientID%>").set_enabled(true);

                if ($find("<%= AddSiteButton.ClientID%>") != null)
                    $find("<%= AddSiteButton.ClientID%>").set_enabled(true);

                if ($find("<%= MarkAreaButton.ClientID%>") != null)
                    $find("<%= MarkAreaButton.ClientID%>").set_enabled(true);

                if ($find("<%= RemoveSiteButton.ClientID%>") != null)
                    $find("<%= RemoveSiteButton.ClientID%>").set_enabled(true);

                if ($find("<%= PhotosButton.ClientID%>") != null)
                    $find("<%= PhotosButton.ClientID%>").set_enabled(true);

                if ($find("<%= ShowRegionsButton.ClientID%>") != null)
                    $find("<%= ShowRegionsButton.ClientID%>").set_enabled(true);

                if ($find("<%=ByDistanceButton.ClientID%>") != null)
                    $find("<%=ByDistanceButton.ClientID%>").set_visible(true);

                if ($find("<%=ShowSitesByDiagramRadButton.ClientID%>") != null)
                    $find("<%=ShowSitesByDiagramRadButton.ClientID%>").set_visible(false);
            }

            function ProcNotCarriedOut_UpdateSelection() {
            }

            function OnSuccess_Update() {
                //update page
                ProcNotCarriedOutCloseDialogueBox();
                RefreshDNASummary();
                disableForDNA();
                setDNAControls();
            }

            function OnError_UpdateReason(jqXHR, textStatus, data) {
                console.log("Failed: UpdateReasonByAjaxCall() ==> !\n\jqXHR: " + jqXHR + ". textStatus: " + textStatus); //
            }

            function ProcNotCarriedOutCloseDialogueBox() {
                return false;
            }

            function showFolderViewer() {
                var ua = window.navigator.userAgent;
                var msie = ua.indexOf("MSIE ");
                // showModalDialog is deprecated and only works in IE
                if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) // If Internet Explorer, show modal window
                {
                    window.showModalDialog('../Products/Common/FolderView.aspx', 'ImagePort Viewer', 'resizable,scrollbars,height=375,width=665');
                }
                else  // If another browser, show window
                {
                    window.open('../Products/Common/FolderView.aspx', 'ImagePort Viewer', 'resizable,scrollbars,height=375,width=665');
                }

                return false;
            }

            function ByDistanceAddClicked(button, args) {
                var txtValAt = $find("<%= ByDistanceAtTextBox.ClientID%>").get_value();
                var txtValTo = $find("<%= ByDistanceToTextBox.ClientID%>").get_value();
                if (txtValAt.trim == '' || txtValAt <= 0 || txtValAt > 9999) {
                    alert('Please enter a valid distance.');
                    return;
                } else {
                    SetByDistanceButtons(false);
                }

                var obj = {};
                $(obj).data('AntPos', 'Both / Either');
                $(obj).data('PositionAssigned', false);
                $(obj).data('RegionId', -77);
                $(obj).data('AreaNo', 0);

                if (txtValTo == '' || txtValTo <= 0) {
                    txtValTo = '0';
                    $(obj).data('Region', txtValAt);
                } else {
                    $(obj).data('Region', txtValAt + ' to ' + txtValTo);
                }

                $(obj).data('Coordinates', txtValAt + ',' + txtValTo);

                InsertSite($(obj));               
                showByDiagram();
            }

            function ByDistanceIndexChanging(list, args) {
                var item = args.get_item();
                if (item.get_index() >= 0) {
                    SetByDistanceButtons(true);
                }
                else {
                    SetByDistanceButtons(false);
                }
            }

            function SetByDistanceButtons(val) {
                if (!$find("<%= ByDistanceRemoveButton.ClientID%>")) return;
                $find("<%= ByDistanceRemoveButton.ClientID%>").set_enabled(val);
            }

            function ByDistanceDeleteSite(button, args) {
                var message = "Are you sure you want to remove this site and all associated data if any?";
                if (confirm(message)) {
                    //button.click();
                    var lb = $find("<%= ByDistanceList.ClientID%>");
                    if (lb.get_selectedItem() == null) return;
                    var siteId = lb.get_selectedItem().get_value();

                    var obj = {};
                    $(obj).data('SiteId', siteId);
                    $(obj).data('AntPos', 'Both / Either');
                    $(obj).data('PositionAssigned', false);
                    $(obj).data('RegionId', -77);
                    $(obj).data('Region', '');
                    //$(obj).data('Coordinates', txtValAt + ',' + txtValTo);
                    $(obj).data('AreaNo', 0);
                    DeleteSiteByDistance($(obj));
                    showByDiagram();
                } else {
                    args.set_cancel(true);
                }
            }

            function byDistanceSiteDetails(button, args) {
                var lb = $find("<%= ByDistanceList.ClientID%>");
                if (lb.get_selectedItem() == 'null') return;

                var optionChosen = $.trim(button._text).replace("...", "");
                if (optionChosen == 'Therapeutic') {
                    optionChosen = 'Therapeutic Procedures'
                } else if (optionChosen == 'Notes') {
                    optionChosen = 'Additional notes'
                }
                button.set_autoPostBack(false);

                var siteId = lb.get_selectedItem().get_value();
                var region = lb.get_selectedItem().get_text();
                lb.get_selectedItem().set_selected(false);
                OpenSiteDetails(region, siteId, optionChosen)
            }

            function OpenSiteDetails(region, siteId, optionChosen, insertionType, areaNo) {
                currentSiteId = siteId;

                //Get a reference to the window.
                var oWnd = $find("<%= SiteDetailsRadWindow.ClientID %>");
                var url = "";
                if (typeof insertionType == 'undefined') insertionType = "";

                if (optionChosen == "Attach Photos") {
                    url = "<%= ResolveUrl("~/Products/Common/Photos.aspx") %>";
                    url = url + "?SiteId={0}";
                    url = url.replace("{0}", siteId);
                }

                oWnd._navigateUrl = url

                //Add the name of the function to be executed when RadWindow is closed.
                oWnd.add_close(OnClientClose);

                oWnd.show();
                if (optionChosen == "Attach Photos") {
                    oWnd.set_behaviors(Telerik.Web.UI.WindowBehaviors.Close);
                    oWnd.maximize();
                }
            }

            function openPapillaryAnatomyWindow() {
                var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
                var url = "<%= ResolveUrl("~/Products/Common/PapillaryAnatomy.aspx") %>";
                oWnd2.SetSize(700, 450);
                oWnd2._navigateUrl = url;
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
            }

            function openResectedColonWindow() {
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
                loadResection();
                getHighlightedColon(resectedColonSet);

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
                }, 200); var oWnd = $find("<%= ResectedColonWindow.ClientID %>");

                oWnd.add_close(OnClientClose);
                oWnd.show();
            }

            function openPhotosWindow() {
                var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
                var url = "<%= ResolveUrl("~/Products/Common/Photos.aspx") %>";
                oWnd2._navigateUrl = url
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(function (sender, args) {
                    SetTreeNode(0);
                });
                oWnd2.show();
                oWnd2.set_behaviors(Telerik.Web.UI.WindowBehaviors.Close);
                oWnd2.maximize();
            }


            function SetTreeNode(siteId) {
                var url = "SiteDetails.aspx?Region={0}&SiteId={1}&OptionChosen={2}&InsertionType={3}&AreaNo={4}";
                url = url.replace("{0}", '');
                url = url.replace("{1}", siteId);
                url = url.replace("{2}", '');
                url = url.replace("{3}", '1');
                url = url.replace("{4}", '1');

                SetUrl(url);
            }

            function SetUrl(url) {

                pane = $find("<%= SiteDetailsMenuRadPane.ClientID %>");

                if (url != null) {
                    //url = ResolveUrl(url);
                    pane.set_contentUrl(url);

                    contentElement = "RAD_SPLITTER_PANE_CONTENT_<%=SiteDetailsMenuRadPane.ClientID %>";
                }
            }

            function CloseResectedColonWindow() {
                var oWnd = $find("<%= ResectedColonWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function OnCloseResectedColonWindow() {
                SaveResectedColon(Array.from(resectedColonSet).filter(item => item).join(','));
                SetTreeNode(0);
            }

            function closeDialog() {
                $find("<%=MessageRadWindow.ClientID%>").close();
            }
            function focusOnDiv(id) {
                const highlightClass = 'highlight-border';
                var $iframeA = $('#RAD_SPLITTER_PANE_EXT_CONTENT_ctl00_ctl00_BodyContentPlaceHolder_pBodyContentPlaceHolder_SiteDetailsMenuRadPane');
                var $iframeB = $iframeA.contents().find('#RAD_SPLITTER_PANE_EXT_CONTENT_SiteDetailsRadPane');
                var $targetElement = $iframeB.contents().find(id);
                //$targetElement.addClass(highlightClass);
                // Apply border style directly
                $targetElement.css({
                    'border': '2px solid red',
                    'transition': 'border 0.3s ease'
                });
                //console.log(id);
                $('html, body').animate({
                    scrollTop: $targetElement.offset().top
                }, 'slow', function () {
                    $targetElement.focus();
                    setTimeout(function () {
                        $targetElement.css('border', '');
                        //$targetElement.removeClass(highlightClass);
                    }, 5000); // Remove after 2 seconds or adjust as needed
                });
            }

            function refreshSiteNode() {
                var mediaSiteId = $('#ProcedureBtn').attr('data-mediaSiteId');
                SetTreeNode(mediaSiteId);
            }

        </script>
    </telerik:RadScriptBlock>
    <telerik:RadAjaxLoadingPanel ID="MyRadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
    <asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server">
        <Scripts>
            <asp:ScriptReference Path="../Scripts/raphael-min.js" />
            <asp:ScriptReference Path="../Scripts/diagram.js" />
            <asp:ScriptReference Path="../Scripts/contextmenu.js" />
            <asp:ScriptReference Path="../Scripts/raphael.export.js" />
            <asp:ScriptReference Path="../Scripts/canvg.js" />
            <asp:ScriptReference Path="../Scripts/jquery-3.6.3.min.js" />
        </Scripts>
    </asp:ScriptManagerProxy>
       <telerik:RadButton runat="server" ID ="ProcedureBtn" AutoPostBack="false" Text="" ClientIDMode="Static" OnClientClicking="refreshSiteNode" data-mediaSiteId="" style="display: none"></telerik:RadButton>
       <div class="validation-modal"></div>
    <div id="ValidationNotification">
        <div class="rnTitleBar">
            <span class="rnTitleBarIcon"></span><span class="rnTitleBarTitle">Please correct the following</span>
            <ul class="rnCommands">
                <li class="rnCloseIcon"><a href="javascript:void(0);" title="Close"></a></li>
            </ul>
        </div>
        <div id="masterValDiv" class="aspxValidationSummary"></div>
        <div style="height: 20px; margin: 0 5px 5px 10px; float: right">
            <telerik:RadButton ID="CloseNotificationButton" runat="server" Text="Close" Skin="Metro" AutoPostBack="false" OnClientClicked="closeNotificationWindow" ButtonType="SkinnedButton"
                Icon-PrimaryIconCssClass="telerikCloseButton" />
        </div>
    </div>
    <telerik:RadNotification ID="ErrorNotification" runat="server" VisibleOnPageLoad="false"
        Skin="Metro" BorderColor="Red" AutoCloseDelay="0" BorderStyle="Ridge" Animation="None" EnableRoundedCorners="true" EnableShadow="true"
        Title="" Width="400" Height="0" TitleIcon="None" ContentIcon="Warning" Position="Center" ShowCloseButton="true" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" Skin="Metro" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
    <div class="otherDataHeading" ondblclick="DisplayProcedureInfo()" style="margin-bottom: 0.5px;">
        <div style="display: flex; align-items: center">
            <%--image added by Ferdowsi, TFS - 4436--%>
            <img runat="server" id="folderViewImage" src="../Images/procedure_image.png" alt="ImagePort Viewer" style="width: 20px; margin-right: 5px;" onclick="showFolderViewer()" />
            <asp:Label ID="ProcedureTypeLabel" runat="server" Text="" Font-Bold="true" />
        </div>
        <div id="divRequirementsKey" runat="server" style="float:right; font-size: small; text-align: right;">
            <img src="../Images/NEDJAG/Mand.png" />Mandatory&nbsp;&nbsp;<img src="../Images/NEDJAG/NED.png" />National Data Set Requirement&nbsp;&nbsp;<img src="../Images/NEDJAG/JAG.png" />JAG Requirement
        </div>
    </div>
    <div>
        <div style="display: inline-block; *display: inline; zoom: 1; vertical-align: top; width: 400px; height: 400px;">
            <div id="diagButtonsDiv" style="height: 45px; background-color: aliceblue; margin-left: 5px; padding-top: 9px;">
                <telerik:RadButton ID="AddSiteButton" runat="server" Text="Add Site" Skin="Metro" Width="60px" AutoPostBack="false" />
                <telerik:RadButton ID="MarkAreaButton" runat="server" Text="Mark Area" Skin="Metro" Width="65px" AutoPostBack="false" OnClientClicked="MarkAreaClicked" />
                <!--<telerik:RadButton ID="Flip180Button" runat="server" Text="Flip 180&#176;" Skin="Metro" Width="65px" Visible="false" />-->
                <telerik:RadButton ID="RemoveSiteButton" runat="server" Text="Remove" Skin="Metro" Width="60px" AutoPostBack="false" OnClientClicked="RemoveSiteClicked" />
                <telerik:RadButton ID="PhotosButton" runat="server" Text="Add Media" Skin="Metro" OnClientClicked="openPhotosWindow" AutoPostBack="false" Width="70px" />
                <telerik:RadButton ID="RefreshDiagramButton" runat="server" Text="Refresh" OnClick="RefreshDiagramButton_Click" AutoPostBack="false" OnClientClicked="refreshParentWithDiagram"/>
                <!-- OnClientClicked="openPhotosWindow"-->
                <telerik:RadButton ID="ShowRegionsButton" runat="server" Text="Regions" Skin="Metro" Width="60px" AutoPostBack="false" OnClientClicked="ShowRegionsButtonClicked" />
            </div>
            <label id="CoordLabel" style="display: none;">0,0</label>
            <div id="PositionLabelDiv" style="margin-left: 5px;">
                <asp:Label ID="PositionLabel" runat="server" Style="position: absolute; height: 10px; text-align: center; width: 380px; font-weight: bold; color: red;" />
            </div>
            <div runat="server" id="divFirstERCP" style="float: right; position: relative;" visible="false">
                <asp:Label ID="lblFirstERCP" runat="server" Text="" Font-Size="Small" Font-Bold="true" BorderStyle="Solid" BorderWidth="1"
                    ForeColor="#993300" Style="border-radius: .2em; margin-right: 10px; padding: 0px 10px;" />
            </div>
            <div id="AddMandatorySitesDiv" runat="server" style="display:none;">
                <asp:CheckBox ID="AddMandatorySitesCheckBox" runat="server" Text="<b>Add mandatory sites</b>" AutoPostBack="false" />
            </div>
            <div id="SpacerDiagramDiv" style="height: 24px;"></div>

            <div id="DiagramDiv" style="height: 400px; margin-left: 5px;">
                <%--<unisoft:diagram ID="SchDiagram" runat="server" Source="PatientProcedure" />--%>
                <%-- <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="RefreshDiagramButton" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>--%>
                <ul id="AddSiteMenu" class="contextMenu">
                    <li><a href="">Anterior</a></li>
                    <li><a href="">Posterior</a></li>
                    <li><a href="">Both / Either</a></li>
                </ul>

                <ul id="EbusSiteClickMenu" class="contextMenu">
                    <li><a href="" style="background-image: url(../Images/icons/abnormalities.png)">Add Abnormalities</a></li>
                    <li class="separator"></li>
                    <li><a href="" style="background-image: url(../Images/icons/camera.png)">Attach Photos</a></li>
                </ul>

                <ul id="SiteClickMenu" class="contextMenu">
                    <li><a href="" style="background-image: url(../Images/icons/camera.png)">Attach Photos</a></li>
                    <li class="separator"></li>
                    <li><a href="" style="background-image: url(../Images/icons/cancel.png)">Remove Site</a></li>
                    <li class="separator"></li>
                    <li><a radio="AntPos" href="">Anterior</a></li>
                    <li><a radio="AntPos" href="">Posterior</a></li>
                    <li><a radio="AntPos" href="">Both / Either</a></li>
                </ul>

                <ul id="LymphNodeSiteClickMenu" class="contextMenu">
                    <li><a href="" style="background-image: url(../Images/icons/camera.png)">Attach Photos</a></li>
                    <li><a href="" style="background-image: url(../Images/icons/cancel.png)">Remove Site</a></li>
                </ul>

                <ul id="ProtocolSiteClickMenu" class="contextMenu">
                    <li><a href="" style="background-image: url(../Images/icons/camera.png)">Attach Photos</a></li>
                </ul>

                <ul id="PhotoRightClickMenu" class="contextMenu">
                    <li><a href="" style="background-image: url(../Images/icons/move_site.png)">Move photo to a different site </a></li>
                    <li><a href="" style="background-image: url(../Images/icons/detach.png)">Detach photo</a></li>
                </ul>
            </div>

            <div id="ByDistanceDiv" style="height: 388px; margin: 15px; padding: 10px; display: none; border: 1px solid #c2d2e2;" class="radPane">
                <asp:UpdatePanel ID="ByDistanceUpdatePanel" runat="server">
                    <ContentTemplate>
                <fieldset style="border: #83AABA solid 1px;">
                    <legend>Sites by distance</legend>
                    Enter distances from insertion point in the appropriate box(es), click 'Add' and then specify abnormalities, specimens, etc.
                </fieldset>
                <table>
                    <tr>
                        <td colspan="2" style="padding-bottom: 5px;">
                            <table style="width: 100%;" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>At (or From)<br />
                                        <telerik:RadNumericTextBox CssClass="spinAlign" ID="ByDistanceAtTextBox" runat="server" NumberFormat-DecimalDigits="0" Width="65" Skin="Office2007" MinValue="1" MaxValue="9999">
                                            <%--<ClientEvents OnValueChanging="DistanceAtValueChanged" OnButtonClick="DistanceAtValueChanged"/>--%>
                                        </telerik:RadNumericTextBox>
                                    </td>
                                    <td style="padding-left: 15px;">To (optionally)<br />
                                        <telerik:RadNumericTextBox CssClass="spinAlign" ID="ByDistanceToTextBox" runat="server" NumberFormat-DecimalDigits="0" Width="65" Skin="Office2007" MinValue="0" MaxValue="9999" />
                                        cm
                                    </td>
                                    <td align="right" style="text-align: right;">&nbsp;<br />
                                        <telerik:RadButton ID="ByDistanceAddRadButton" runat="server" Text="Add" Skin="Office2007" Width="70" OnClientClicked="ByDistanceAddClicked" Icon-PrimaryIconUrl="~/Images/icons/create.png" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-top: 5px; width: 173px; border-top: 1px dashed lightgray;">
                            <telerik:RadListBox ID="ByDistanceList" runat="server" Height="230px" Width="167px" OnClientSelectedIndexChanged="" Skin="Office2007"
                                DataSourceID="ByDistanceSqlDataSource" DataTextField="Distance" DataValueField="SiteId" OnClientSelectedIndexChanging="ByDistanceIndexChanging">
                            </telerik:RadListBox>
                            <asp:ObjectDataSource ID="ByDistanceSqlDataSource" runat="server" SelectMethod="GetSiteDetailsByDistance" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
                        </td>
                        <td style="vertical-align: top; padding-top: 30px; text-align: right; border-top: 1px dashed lightgray;">
                            <telerik:RadButton ID="ByDistanceRemoveButton" runat="server" Text="Remove" Enabled="false" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/Cancel.png" OnClientClicked="ByDistanceDeleteSite" />
                            <br />
                            <br />
                            <%-- <telerik:RadButton ID="ByDistanceAbnormalitiesRadButton" runat="server" Text=" Abnormalities" OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/abnormalities.png" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceTherapeuticRadButton" runat="server" Text=" Therapeutic..." OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/therapeutic.png" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceSpecimensRadButton" runat="server" Text="Specimens" OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/specimen.png" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceNotesRadButton" runat="server" Text="Notes" OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/notes.png" />--%>
                        </td>
                    </tr>
                </table>
                 </ContentTemplate>
                 <%-- <Triggers>
                       <asp:AsyncPostBackTrigger ControlID="Flip180Button" EventName="Click" />
                  </Triggers>--%>
                </asp:UpdatePanel>
            </div>

            <%--<div style="height: 10px;"></div>--%>
            <div id="PapillaryAnatomyButtonDiv" runat="server" style="vertical-align: bottom; display: none; padding-top: 10px; padding-bottom: 10px;">
                <div id="ERCPDiagramFooterDiv" style="margin-left: 5px; margin-top: 5px;">
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td colspan="3">
                                <asp:CheckBox ID="PancreasDivisumCheckBox" runat="server" Text="Pancreas divisum present" AutoPostBack="true" />
                            </td>
                            <td align="center">
                                <telerik:RadButton ID="PapillaryAnatomyButton" runat="server" Text="Papillary anatomy" Skin="Metro" OnClientClicked="openPapillaryAnatomyWindow" AutoPostBack="false" ButtonType="SkinnedButton" />
                            </td>
                        </tr>
                        <tr runat="server" visible="false">
                            <td>
                                <asp:Label ID="Label4" runat="server" Text="Manometry:" ForeColor="Black" />
                            </td>
                            <td>
                                <asp:CheckBox ID="BiliaryCheckBox" runat="server" Text="biliary" AutoPostBack="true" />
                            </td>
                            <td>
                                <asp:CheckBox ID="PancreaticCheckBox" runat="server" Text="pancreatic" AutoPostBack="true" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <%--<div style="height: 10px;"></div>--%>

            <div id="UpperGIDiv" runat="server" style="vertical-align: bottom; margin-left: 115px; display: none;">
                <div id="UpperGIFooterDiv" style="margin-left: 10px;">
                    <table width="100%" cellpadding="5" cellspacing="5">
                        <tr>
                            <td>
                                <asp:CheckBox ID="TransnasalCheckBox" runat="server" Text="<b>Transnasal endoscopy</b>" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="EUSDiv" runat="server" style="vertical-align: bottom; margin-left: 115px; display: none;">
                <div id="EUSFooterDiv" style="margin-left: 10px;">
                    <table width="100%" cellpadding="5" cellspacing="5">
                        <tr>
                            <td>
                                <asp:CheckBox ID="EUSCompleteCheckBox" runat="server" Text="<b>Procedure completed successfully</b>" AutoPostBack="false" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="ResectedColonDiv" runat="server" style="vertical-align: bottom; display: none;">
                <div style="padding-left: 10px;">
                    <telerik:RadButton ID="ByDistanceButton" runat="server" ButtonType="SkinnedButton" OnClientClicked="showByDistance" Visible="true"
                        AutoPostBack="false" Skin="Metro" Icon-PrimaryIconUrl="~/images/icons/measurement.gif" Text="by Distance">
                    </telerik:RadButton>
                    <telerik:RadButton ID="ShowSitesByDiagramRadButton" runat="server" ButtonType="SkinnedButton" OnClientClicked="showByDiagram"
                        AutoPostBack="false" Skin="Metro" Icon-PrimaryIconUrl="~/images/icons/colon.png" Text="By diagram">
                    </telerik:RadButton>
                    <span style="padding-right: 96px;"></span>
                    <telerik:RadButton ID="ResectedColonButton" runat="server" Text="Resected colon" Skin="Metro" ForeColor="#993333" AutoPostBack="false" OnClientClicked="openResectedColonWindow" Icon-PrimaryIconUrl="~/Images/icons/Resected.png" />
                </div>
            </div>


        </div>
        <div id="SiteDetails" class="procedure-form" style="display: inline-block; *display: inline; zoom: 1; vertical-align: top; position: relative; width: 550px;">
            <telerik:RadSplitter ID="SiteDetailsRadSplitter" runat="server" BorderWidth="1" Orientation="Vertical" Skin="Metro" Width="750px">
                <telerik:RadPane ID="SiteDetailsMenuRadPane" runat="server" Scrolling="Both" BackColor="#dfe9f5" MinWidth="700" Width="750px">
                </telerik:RadPane>
            </telerik:RadSplitter>
        </div>
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel2" runat="server" Skin="Metro" />
    </div>

    <telerik:RadWindowManager ID="ResectedColonWindowManager" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
        <Windows>
            <telerik:RadWindow ID="SiteDetailsRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="950px" CssClass="summaryPrev" VisibleStatusbar="false" Behaviors="Move" />
            <telerik:RadWindow ID="MessageRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="250px" VisibleStatusbar="false" VisibleOnPageLoad="false" Visible="false" Title="Previous gastric ulcer" BackColor="#ffffcc">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                <img id="infoImage" runat="server" src="~/Images/info-32x32.png" />
                            </td>
                            <td style="text-align: center; padding: 20px;">
                                <asp:Label ID="lblPreviousGastricUlcer" runat="server" Font-Size="Large" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="padding: 10px; text-align: center;">
                                <telerik:RadButton ID="OkRadButton" runat="server" Text="OK" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeDialog" Width="100" Height="30" Font-Size="Large" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </telerik:RadWindow>
            <telerik:RadWindow ID="ResectedColonWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="840px" CssClass="summaryPrev" Title="Resected Colons" VisibleStatusbar="false" Animation="None" OnClientClose="OnCloseResectedColonWindow">
                <ContentTemplate>
                    <div id="tempDiv" style="display: none"></div>
                    <table cellspacing="15">
                        <tr>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="IntactColonCanvas" style="display: none;"></canvas>
                                    <img id="IntactColonImg" alt="" height="100" width="100" value="0" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center; vertical-align: bottom;">Intact Colon</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="AbdominoPerinealCanvas" style="display: none;"></canvas>
                                    <img id="AbdominoPerinealImg" alt="" height="100" width="100" value="1" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Abdomino-perineal resection</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="LowAnteriorCanvas" style="display: none;"></canvas>
                                    <img id="LowAnteriorImg" alt="" height="100" width="100" value="2" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Low anterior resection</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="SigmoidColectomyCanvas" style="display: none;"></canvas>
                                    <img id="SigmoidColectomyImg" alt="" height="100" width="100" value="3" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Sigmoid colectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="HighAnteriorCanvas" style="display: none;"></canvas>
                                    <img id="HighAnteriorImg" alt="" height="100" width="100" value="4" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">High anterior</div>
                            </td>
                        </tr>
                        <tr>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="HartmannsProcedureCanvas" style="display: none;"></canvas>
                                    <img id="HartmannsProcedureImg" alt="" height="100" width="100" value="12" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Hartmann's procedure</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="LeftHemicolectomyCanvas" style="display: none;"></canvas>
                                    <img id="LeftHemicolectomyImg" alt="" height="100" width="100" value="11" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Left hemicolectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="TransverseColectomyCanvas" style="display: none;"></canvas>
                                    <img id="TransverseColectomyCanvasImg" alt="" height="100" width="100" value="5" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Transverse colectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="RightHemicolectomyCanvas" style="display: none;"></canvas>
                                    <img id="RightHemicolectomyImg" alt="" height="100" width="100" value="6" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Right hemicolectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="ExtendedRightHemicolectomyCanvas" style="display: none;"></canvas>
                                    <img id="ExtendedRightHemicolectomyImg" alt="" height="100" width="100" value="7" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Extended right hemicolectomy</div>
                            </td>
                        </tr>
                        <tr>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="SubtotalColectomyCanvas" style="display: none;"></canvas>
                                    <img id="SubtotalColectomyImg" alt="" height="100" width="100" value="8" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center; vertical-align: middle;">Subtotal colectomy with ileorectal anastomosis</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="SubtotalColectomyStumpCanvas" style="display: none;"></canvas>
                                    <img id="SubtotalColectomyStumpImg" alt="" height="100" width="100" value="13" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Subtotal colectomy, ileostomy & rectal stump</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="TotalColectomyCanvas" style="display: none;"></canvas>
                                    <img id="TotalColectomyImg" alt="" height="100" width="100" value="9" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Total colectomy plus ileal pouch</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="PanProctoColectomyCanvas" style="display: none;"></canvas>
                                    <img id="PanProctoColectomyImg" alt="" height="100" width="100" value="10" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Pan procto colectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="IleocaecectomyCanvas" style="display: none;"></canvas>
                                    <img id="IleocaecectomyImg" alt="" height="100" width="100" value="14" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Ileocaecectomy</div>
                            </td>
                        </tr>
                    </table>

                    <div id="buttonsdiv" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central; text-align: center;">
                        <telerik:RadButton ID="CloseResectedButton" runat="server" Text=" Close " Skin="Metro" AutoPostBack="false" OnClientClicked="CloseResectedColonWindow" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>


</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="server">
</asp:Content>
