<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="BlankReports.aspx.vb" Inherits="UnisoftERS.Products_Reports_BlankReports" %>
<%@ Register TagPrefix="unisoft" TagName="Diagram" Src="~/UserControls/diagram.ascx" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Print Report</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <link type="text/css" href="../../Styles/PrintReport.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $("input[type=number]").hide();
            $(".lbl").hide();
            $("#Button").hide();
            $("input[type=checkbox]").change(function () {
                var o = "#N".concat($(this).get(0).id);
                var p = "#LN".concat($(this).get(0).id);
                $(o).toggle(this.checked);
                $(p).toggle(this.checked);
                var t = $("input[type=checkbox]:checked").length;
                if (t == 0) { $("#Button").hide(); }
                else { $("#Button").show(); }
            });
            $("input[type=number]").change(function () {
                var n = $(this).val();
                var m = "#L".concat($(this).get(0).id);
                if (n == "1") {
                    $(m).text("Copy");
                } else {
                    $(m).text("Copies");
                }
            });
        });

        $(window).on('load', function () {

        });
    </script>

    <style type="text/css">
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PrintRadScriptManager" runat="server"/>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div style="overflow: hidden; height: 470px; width: 760px; border: 1px solid #D0D0D0;" class="ReportBg" >
            <fieldset id="ReportSelectProcType" style="margin-left: 20px; margin-top: 20px; width: 50%;" runat="server">
                <legend>Select report</legend>
                <table cellspacing="10px">
                    <tbody>
                        <tr>
                            <td>
                                <asp:CheckBox ID="OGD" runat="server" Skin="Web20" Text="Gastroscopy" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NOGD" step="1" min="1" max="100" value="1" runat="server" id="NOGD" size="3" />
                                <label class="lbl" for="NOGD" id="LNOGD">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="ERC" runat="server" Skin="Web20" Text="ERCP report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NERC" step="1" min="1" max="100" value="1" runat="server" id="NERC" size="3" />
                                <label class="lbl" for="NERC" id="LNERC">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="COL" runat="server" Skin="Web20" Text="Colonoscopy report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NCOL" step="1" min="1" max="100" value="1" runat="server" id="NCOL" size="3" />
                                <label class="lbl" for="NCOL" id="LNCOL">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="SIG" runat="server" Skin="Web20" Text="Sigmoidoscopy report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NSIG" step="1" min="1" max="100" value="1" runat="server" id="NSIG" size="3" />
                                <label class="lbl" for="NSIG" id="LNSIG">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="PRO" runat="server" Skin="Web20" Text="Proctoscopy report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NPRO" step="1" min="1" max="100" value="1" runat="server" id="NPRO" size="3" />
                                <label class="lbl" for="NPRO" id="LNPRO">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="EUS" runat="server" Skin="Web20" Text="Endoscopic ultrasound (UGI) report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NEUS" step="1" min="1" max="100" value="1" runat="server" id="NEUS" size="3" />
                                <label class="lbl" for="NEUS" id="LNEUS">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="HPB" runat="server" Skin="Web20" Text="Endoscopic ultrasound (HPB) report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NHPB" step="1" min="1" max="100" value="1" runat="server" id="NHPB" size="3" />
                                <label class="lbl" for="NHPB" id="LNHPB">Copy</label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="BRO" runat="server" Skin="Web20" Text="Bronchoscopy report" AutoPostBack="false" Enabled="true" />
                            </td>
                            <td>
                                <input type="number" name="NBRO" step="1" min="1" max="100" value="1" runat="server" id="NBRO" size="3" />
                                <label class="lbl" for="NBRO" id="LNBRO">Copy</label>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </fieldset>
            <fieldset id="Button" style="margin-left: 20px; margin-top: 20px; width: 50%;text-align:center;" runat="server">
                <telerik:RadButton ID="Print" runat="server" Text="Print" Skin="Web20" ValidationGroup="FilterGroup" ButtonType="SkinnedButton" SkinID="RadSkinManager1" Height="30px" Width="200px"></telerik:RadButton>
            </fieldset>
<%--            <div style="overflow: hidden; height: 470px; width: 760px; border: 1px solid #D0D0D0;" class="ReportBg">
                <fieldset id="ReportSelectFieldset" style="margin-left: 20px; margin-top: 20px; width: 60%;" runat="server">
                    <legend>Select report</legend>
                    <table cellspacing="10px">
                        <tbody>
                            <tr>
                                <td></td>
                                <td style="padding-left: 100px;">
                                    <telerik:RadButton ID="PrintButton" runat="server" Text="Print" Skin="Web20" Width="80px" OnClientClicked="PrintReports" AutoPostBack="false" />
                                </td>
                                <td>
                                    <telerik:RadButton ID="ConfigureButton" runat="server" Text="Configure" Skin="Web20" Width="80px" OnClientClicked="OpenPrintConfigureWindow" AutoPostBack="false" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </fieldset>
            </div>--%>
        </div>
<%--        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="false"
            Style="z-index: 7001" Behaviors="Close, Move" Skin="Office2007" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="PrintWindow" runat="server" Title="Print report"
                    Width="850px" Height="900px" ReloadOnShow="true" ShowContentDuringLoad="false"
                    Modal="true" VisibleStatusbar="false" Skin="Office2010Blue" OnClientShow="showContentForIE" Behaviors="Close">
                </telerik:RadWindow>
                <telerik:RadWindow ID="PrintConfigureWindow" runat="server" Title="Configure Print Reports"
                    Width="950px" Height="600px" ReloadOnShow="true" ShowContentDuringLoad="false"
                    Modal="true" VisibleStatusbar="false" Skin="Office2010Blue" Behaviors="Close">
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>--%>
    </form>
</body>
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function () {
                if (xhttp.readyState == 4 && xhttp.status == 200) {
                    document.getElementById("svgimage").innerHTML = xhttp.responseText;
                }
            };
            xhttp.open("GET", "~/Images/OGD.svg", true);
            xhttp.send();
        });

<%--        function OpenPrintConfigureWindow() {
            var oWnd = $find("<%= PrintConfigureWindow.ClientID%>");
            var url = "<%= ResolveUrl("~/Products/Common/PrintOptions.aspx") %>";

            //oWnd.SetSize(950, 600);
            oWnd._navigateUrl = url
            oWnd.show();
            return false;
        }--%>
<%--        function ShowPrintWindow(url) {
            var oWnd = $find("<%= PrintWindow.ClientID %>");
            oWnd._navigateUrl = url;
            oWnd.show();
            oWnd.moveTo(283, 0);
        }--%>
        function FixPageViewHeight() {
            var height = $(window).height();

            var validateWard;
            function ToggleWard(selectedText) {
                <%If Not CBool(Session("isERSViewer")) Then%>

                if ((selectedText != null) && (selectedText.indexOf("Inpatient") == 0)) {
                    wardDiv1.show();
                    wardDiv2.show();
                    validateWard = true;
                }
                else {
                    wardDiv1.hide();
                    wardDiv2.hide();
                    validateWard = false;
                }
                <%End If%>
            }
        }
        function ApplyTooltip(descr) {
            $(".rigThumbnailsBox img[alt='" + descr + "']").qtip({
                content:
                     descr
                ,
                style: {
                    classes: 'tooltip-myStyle'
                }
            })
        }


        function OnClientHiding(sender, eventArgs) {
            window.location.replace(sender.get_value());
        }

            function PrintReports() {
                var rText = "";//getRequiredFieldText();
                if (rText != null && rText != '') {
                    rtxt = rText.split('|');
                    document.getElementById("valDiv").innerHTML = rtxt[0];
                } else {                    
                    procId = 0;//node.get_attributes().getAttribute("ProcedureId");
                    epiNo = 0;//node.get_attributes().getAttribute("EpisodeNo");
                    procTypeId = "2";//node.get_attributes().getAttribute("ProcedureType");
                    cType = "";//node.get_attributes().getAttribute("ColonType");
                    GetDiagramScript();
                }
            }

            var documentUrl = document.URL;
            var procId=0;
            var epiNo=0;
            var procTypeId=2;   /*ojito*/
            var cType="";
            var cnn="";


            function GetDiagramScript() {
                var jsondata =
                {
                    procedureIdFromJS: procId,
                    episodeNoFromJS: epiNo,
                    procedureTypeIdFromJS: procTypeId,
                    colonType: cType
                };

                $.ajax({
                    type: "POST",
                    url: documentUrl.slice(0, docURL.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/GenerateDiagram",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: GetDiagramScriptSuccess,
                    error: function (jqXHR, textStatus, data) {
                        //var vars = jqXHR.responseText.split("&"); 
                        //alert(vars[0]); 
                        alert("Unknown error occured while generating report. Please contact HD Clinical helpdesk.");
                    }
                });
            }
            function GetDiagramScript() {
                $.ajax({
                    type: "POST",
                    url: documentUrl.slice(0, docURL.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/GenerateDiagram",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: GetDiagramScriptSuccess,
                    error: function (jqXHR, textStatus, data) {
                        //var vars = jqXHR.responseText.split("&"); 
                        //alert(vars[0]); 
                        alert("Unknown error occured while generating report. Please contact HD Clinical helpdesk.");
                    }
                });
            }

            function GetDiagramScriptSuccess(responseText) {
                $("#mydiagramDiv").html(responseText.d);

                $("#mydiagramDiv").find("script").each(function (i) {
                    var svgXml = eval($(this).text());

                    if (svgXml == undefined) {
                        svgXml = "No diagram";
                    }
                    canvg('myCanvas', svgXml, { renderCallback: GetImgDataUri, ignoreMouse: true, ignoreAnimation: true });
                });
            }

            <%--function OpenPrintWindow(cnn) {
                var url = "<%= ResolveUrl("~/Products/Common/PrintReport.aspx") %>";

                if (cnn) {
                    url = url + "?CNN=" + cnn;
                    window.location.href = url;
                }
                else {
                    var oWnd = $find("<%= PrintWindow.ClientID %>");

                    url = url + "?PrintGPReport={1}";
                    url = url + "&PrintPhotosReport={2}";
                    url = url + "&PrintPatientCopyReport={3}";
                    url = url + "&PrintLabRequestReport={4}";
                    url = url + "&Resected={5}";
                    url = url.replace("{1}", true);
                    url = url.replace("{2}", false);
                    url = url.replace("{3}", false);
                    url = url.replace("{4}", false);
                    url = url.replace("{5}", getResectionTexts());

                    //oWnd.SetSize(850, 900);
                    oWnd._navigateUrl = url;
                    oWnd.show();
                    oWnd.moveTo(283, 0);
                    return false;
                }
            }--%>
/*Rubish?*/
            function highlightListControl(elementRef) {
                var inputElementArray = elementRef.getElementsByTagName('input');

                for (var i = 0; i < inputElementArray.length; i++) {
                    var inputElementRef = inputElementArray[i];
                    var parentElement = inputElementRef.parentNode;

                    if (parentElement) {
                        if (inputElementRef.checked == true) {
                            $(parentElement).addClass('rdChecked');
                        }
                        else {
                            $(parentElement).removeClass('rdChecked');

                        }
                    }
                }

            }
        var printChosen;

        function showContentForIE(wnd) {
            if ($telerik.isIE)
                wnd.view.onUrlChanged();
        }

    </script>
</telerik:RadCodeBlock>
</html>
