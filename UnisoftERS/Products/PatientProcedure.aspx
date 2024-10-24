<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_PatientProcedure" CodeBehind="PatientProcedure.aspx.vb" %>

<%@ Register TagPrefix="unisoft" TagName="diagram" Src="~/UserControls/diagram.ascx" %>
<%@ Register Src="~/UserControls/PatientDetails.ascx" TagPrefix="unisoft" TagName="PatientDetails" %>
<%@ Register Src="~/UserControls/procedurefooter.ascx" TagPrefix="unisoft" TagName="procedurefooter" %>



<asp:Content ID="IDHead" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">

    <title></title>
    <%--   <script type="text/javascript" src="../../Scripts/jquery-1.11.0.min.js"></script>
   <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael-min.js"></script>
    <script type="text/javascript" src="../../Scripts/diagram.js"></script>
    <script type="text/javascript" src="../../Scripts/contextmenu.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael.export.js"></script>
    <script type="text/javascript" src="../../Scripts/canvg.js"></script>--%>
    <link href="../Styles/contextmenu.css" rel="stylesheet" />
    <style type="text/css">
        .diagram-buttons {
            color: #050;
            font: bold 84% 'trebuchet ms',helvetica,sans-serif;
            /*font: bold 84% 'trebuchet ms',helvetica,sans-serif;*/
            /*font-family: Georgia;*/
            font-size: 8pt;
            background-color: #fed;
            border: 1px solid;
            border-color: #696 #363 #363 #696;
        }

        a.sitesummary {
            color: inherit;
        }

            a.sitesummary:link {
                text-decoration: none;
                color: inherit;
            }

            a.sitesummary:hover {
                text-decoration: underline;
                color: blue;
            }

        .rigThumbnailsList {
            background-color: white !important;
        }

            .rigThumbnailsList li {
                background-color: none !important;
            }

            .rigThumbnailsList img {
                opacity: 1 !important;
                border-radius: 10px;
            }

            .rigThumbnailsList a:hover img {
                opacity: 1 !important;
            }

            .rigThumbnailsList .rigThumbnailActive a img {
                opacity: 1 !important;
            }

        .rltbDescription {
            display: none;
        }

        .rltbActiveImage {
            height: 400px !important;
        }

        .txtSiteHighlight {
            padding-left: 5px;
            padding-right: 5px;
            background-color: #ffff99;
            box-shadow: 0 0 7px #cccc00;
        }

        .imageWrapper {
            font: 13px "Segoe UI", Arial,Helvetica, sans-serif;
            color: #666;
            float: left;
            width: 194px;
            height: 150px;
            padding: 10px;
            cursor: pointer;
        }

        .playIcon {
            background: url('../Images/hover_video_thumb.png') no-repeat;
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            display: none;
        }

        .imageWrapper:hover {
            background: white;
            color: #000;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
        }

            .thumbnailHolder img,
            .imageWrapper:hover .playIcon {
                display: block;
            }

        .thumbnailHolder {
            display: block;
            position: relative;
            margin-bottom: 5px;
        }

        .timeLabel {
            background-color: rgba(0,0,0,0.7);
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#B3000000', endColorstr='#B3000000',GradientType=0 );
            font: bold 10px/14px "Segoe UI", Arial,Helvetica, sans-serif;
            color: white;
            bottom: 2px;
            right: 1px;
            width: 30px;
            text-align: center;
            position: absolute;
        }

        .RadMediaPlayer,
        div.rltbDescriptionBox {
            margin-left: 50px;
            width: 600px;
        }

        .rltbItemTemplate {
            height: 336px;
        }

        .rmpFullscreen {
            margin-left: 0px;
        }

        div.RadLightBox .rltbWrapper {
            z-index: auto;
        }

        .RadLightBox .rltbToolbar {
            display: none;
        }

        .rltbOverlay {
            z-index: 350000 !important;
        }

        .RadLightBox {
            z-index: 360000 !important;
        }

        .size-custom {
            max-width: 642px;
        }

        /* PatientDetails.ascx=> Styles */
        .lefthide {
            float: left;
            display: none;
            color: red;
            font-weight: bold;
        }

        .UGI_Procedure {
            color: red;
        }

        .LockedProcedure {
            color: #990033;
        }

        .ProcedureIncomplete {
            color: #1E90FF;
        }

        .divProcDNA {
            float: right;
            text-align: right;
            margin-left: 10px;
        }

            .divProcDNA a {
                font-size: 10px;
                margin-left: 0px;
            }
    </style>
</asp:Content>

<asp:Content ID="DiagramPaneContent" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="Server">
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            var docURL = document.URL;
            var webMethodLocation = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Default.aspx/";

            function showProcNotCarriedOutWindow() {
                var oWnd = $find("<%= ProcNotCarriedOutRadWindow.ClientID%>");
                oWnd.set_title("Procedure NOT carried out");
                oWnd.show();
            }

            $(document).ready(function () {

                $("#IDBody").css("cursor", "progress");

                $("#<%=CancelledProcCheckBox.ClientID%>").on("click", function () {
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


                $("#<%=ProcNotCarriedOutCheckBox.ClientID%>").on('change', function () {
                    if ($(this).is(":checked")) {
                        showProcNotCarriedOutWindow();
                    }
                });

                $('#<%=ProcNotCarriedOutRadioButtonList.ClientID%> input').on('change', function (sender, args) {
                    var selectedReasonId = $(this).val();
                    var PP_DNA_Text = '';

                    //### Build the PP_DNA Text for ERS_ProceduresReporting
                    if (selectedReasonId == '1')
                        PP_DNA_Text = 'Patient DNA this procedure';
                    else if (selectedReasonId == '2')
                        PP_DNA_Text = 'Patient cancelled this procedure';
                    else if (selectedReasonId == '3')
                        PP_DNA_Text = 'Hospital cancelled this procedure';

                    var selectedProcedureTypeId = <%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>;
                    if (selectedProcedureTypeId == 1) {
                        PP_DNA_Text += " and a colon/sigmoidoscopy";
                        $("#chkPatientDNA_Text").show();  //Only shown if a double procedure can be done
                        $("#lblDNA_PP_Text").text(PP_DNA_Text);
                    }
                    else if (selectedProcedureTypeId == 3 || selectedProcedureTypeId == 4) {
                        PP_DNA_Text += " and a gastroscopy";
                        $("#chkPatientDNA_Text").show();  //Only shown if a double procedure can be done
                        $("#lblDNA_PP_Text").text(PP_DNA_Text);
                    }


                    $find("<%= btnProcNotcarriedOutSubmit.ClientID%>").set_enabled(true);

                });
            });


            function SitesByDistance(sender, args) {
                var currentState = sender.get_selectedToggleState();
                //alert(currentState.get_text());
                //alert($find("ByDistanceButton").get_selectedToggleState().get_text());
                if (currentState.get_text() == 'by Distance') {
                    $('#DiagramDiv').show();
                    $('#PositionLabelDiv').show();
                    $('#SpacerDiagramDiv').show();
                    $find("<%= ResectedColonButton.ClientID%>").set_enabled(true);
                    $find("<%= AddSiteButton.ClientID%>").set_enabled(true);
                    $find("<%= MarkAreaButton.ClientID%>").set_enabled(true);
                //$find("<%= Flip180Button.ClientID%>").set_enabled(true);
                    $find("<%= RemoveSiteButton.ClientID%>").set_enabled(true);
                //$find("<%= PhotosButton.ClientID%>").set_enabled(true);
                    $find("<%= ShowRegionsButton.ClientID%>").set_enabled(true);
                    $('#ByDistanceDiv').hide();
                } else {
                    $('#DiagramDiv').hide();
                    $('#PositionLabelDiv').hide();
                    $('#SpacerDiagramDiv').hide();
                    $find("<%= ResectedColonButton.ClientID%>").set_enabled(false);
                    $find("<%= AddSiteButton.ClientID%>").set_enabled(false);
                    $find("<%= MarkAreaButton.ClientID%>").set_enabled(false);
                //$find("<%= Flip180Button.ClientID%>").set_enabled(false);
                    $find("<%= RemoveSiteButton.ClientID%>").set_enabled(false);
                //$find("<%= PhotosButton.ClientID%>").set_enabled(false);
                    $find("<%= ShowRegionsButton.ClientID%>").set_enabled(false);
                    $('#ByDistanceDiv').show();
                }
            }

            function ProcNotCarriedOut_UpdateSelection() {
                var selectedProcedureId = <%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>;
                var selectedReason = $('#<%=ProcNotCarriedOutRadioButtonList.ClientID%> input:checked');
                var selectedReasonId = selectedReason.val();
                var PP_DNA_Text = selectedReason.parent().text();

                var webMethodUrl = document.URL.slice(0, docURL.indexOf("/Products/")) + "/Products/Default.aspx/ProcedureNotCarriedOut_UpdateReason";
                var jsonData = JSON.stringify({
                    procedureId: selectedProcedureId,
                    DNA_ReasonId: selectedReasonId,
                    PP_DNA_Text: PP_DNA_Text
                });

                console.log("jsonData: " + jsonData);
                console.log("webMethodUrl: " + webMethodUrl);

                ///return; //#### do nothing
                $.ajax({
                    type: "POST",
                    url: webMethodUrl,
                    data: jsonData,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        OnSuccess_Update(data)
                    },
                    error: function (jqXHR, textStatus, data) {
                        OnError_UpdateReason(jqXHR, textStatus, data);
                    }
                });
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
                var oWnd = $find("<%= ProcNotCarriedOutRadWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
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

            function DisplayProcedureInfo() {
                var procID = '<%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>';
                var patientID ='<%=Session(UnisoftERS.Constants.SESSION_PATIENT_ID)%>';
                var appVersion = '<%=Session(UnisoftERS.Constants.SESSION_APPVERSION)%>';
                var operatingHospital = '<%=Session("OperatingHospitalID")%>';
                var userID = '<%=Session("UserID")%>';
                var roomID = '<%=Session("RoomId")%>';
                var imagePortId = '<%=Session("PortId")%>';
                var imagePortName = '<%=Session("PortName")%>';
                alert('App Version: ' + appVersion + '\nPatientID: ' + patientID + '\nProcedureID: ' + procID + '\nOperatingHospital: ' + operatingHospital + '\nUserID: ' + userID + '\nRoomID: ' + roomID + '\nPortId: ' + imagePortId + '\nPortName: ' + imagePortName);
            }
        </script>
    </telerik:RadScriptBlock>

    <asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server">
        <Scripts>
            <asp:ScriptReference Path="../Scripts/raphael-min.js" />
            <asp:ScriptReference Path="../Scripts/diagram.js" />
            <asp:ScriptReference Path="../Scripts/contextmenu.js" />
            <asp:ScriptReference Path="../Scripts/raphael.export.js" />
            <asp:ScriptReference Path="../Scripts/canvg.js" />
        </Scripts>
    </asp:ScriptManagerProxy>

    <%--<telerik:RadPane ID="DiagramRadPane" runat="server" Width="360">--%>
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" Skin="Web20" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadSplitter ID="DiagramRadSplitter" runat="server" Orientation="Horizontal" Skin="Windows7">
        <telerik:RadPane ID="DiagramImageRadPane" runat="server" Width="450" Height="560" Scrolling="None">
            <div class="text12" style="float: left;">Instruments </div>
            <img runat="server" id="folderViewImage" src="../Images/image.png" alt="ImagePort Viewer" onclick="showFolderViewer()" />
            <div runat="server" id="divFirstERCP" style="float: right; position: relative;" visible="false">
                <asp:Label ID="lblFirstERCP" runat="server" Text="" Font-Size="Small" Font-Bold="true" BorderStyle="Solid" BorderWidth="1"
                    ForeColor="#993300" Style="border-radius: .2em; margin-right: 10px; padding: 0px 10px;" />
            </div>
            <div id="divScopeGuide" runat="server" style="float: right;" visible="false">Scope guide used?</div>
            <%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>--%>
            <table id="tblInstruments" runat="server" style="margin-left: 15px; width: 94%;">
                <tr>
                    <td>
                        <asp:Label ID="Label1" runat="server" Text="1st Scope" />
                    </td>
                    <td>
                        <telerik:RadComboBox ID="cboInstrument1" runat="server" Skin="Vista" AutoPostBack="true" Filter="Contains" />
                    </td>
                    <td id="tdScopeGuide" rowspan="3" runat="server" style="text-align: center; border-left: 1px dashed lightgray; vertical-align: top;" visible="false">
                        <asp:Image runat="server" ID="Image1" ImageUrl="~/Images/pointer_down.png" /><br />
                        <asp:RadioButtonList ID="rbScopeGuide" runat="server" AutoPostBack="true" RepeatDirection="Vertical" RepeatLayout="Flow">
                            <asp:ListItem Text="No" Value="0" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                        </asp:RadioButtonList>
                    </td>
                </tr>
                <tr id="Scope2Section" runat="server">
                    <td>
                        <asp:Label ID="Label2" runat="server" Text="2nd Scope" />
                    </td>
                    <td>
                        <telerik:RadComboBox ID="cboInstrument2" runat="server" Skin="Vista" AutoPostBack="true" Filter="Contains" />
                    </td>
                </tr>
                <tr id="AccessMethodSection" runat="server" visible="false">
                    <td>
                        <asp:Label ID="AccessMethodLabel" runat="server" Text="Access Via" />
                    </td>
                    <td>
                        <telerik:RadComboBox ID="AccessMethodComboBox" runat="server" Skin="Vista" AutoPostBack="true" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="DistalAttachmentLabel" runat="server" Text="Distal Attachment" /></td>
                    <td>
                        <telerik:RadComboBox ID="DistalAttachmentRadComboBox" runat="server" Skin="Vista" AutoPostBack="true" Filter="StartsWith" DataTextField="Description" DataValueField="UniqueId" />
                    </td>
                </tr>
            </table>
            <%--</ContentTemplate>
            </asp:UpdatePanel>--%>
            <label id="CoordLabel" style="display: none;">0,0</label>
            <div id="PositionLabelDiv" style="margin-left: 5px;">
                <asp:Label ID="PositionLabel" runat="server" Style="position: absolute; height: 10px; text-align: center; width: 350px; font-weight: bold; color: red;" />
            </div>
            <div id="SpacerDiagramDiv" style="height: 30px;"></div>

            <div id="DiagramDiv" style="margin-left: 5px;">
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <unisoft:diagram ID="SchDiagram" runat="server" Source="PatientProcedure" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="Flip180Button" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>

            <div id="ByDistanceDiv" style="height: 378px; margin: 15px; padding: 10px; display: none; border: 1px solid #c2d2e2;" class="radPane">
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
                                                <telerik:RadNumericTextBox CssClass="spinAlign" ID="ByDistanceAtTextBox" runat="server" NumberFormat-DecimalDigits="0" ShowSpinButtons="true" Width="80" Skin="Office2007" MinValue="1" MaxValue="9999">
                                                    <%--<ClientEvents OnValueChanging="DistanceAtValueChanged" OnButtonClick="DistanceAtValueChanged"/>--%>
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td style="padding-left: 15px;">To (optionally)<br />
                                                <telerik:RadNumericTextBox CssClass="spinAlign" ID="ByDistanceToTextBox" runat="server" NumberFormat-DecimalDigits="0" ShowSpinButtons="true" Width="80" Skin="Office2007" MinValue="0" MaxValue="9999" />
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
                                    <telerik:RadButton ID="ByDistanceRemoveButton" runat="server" Text="Remove" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/Cancel.png" OnClientClicked="ByDistanceDeleteSite" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceAbnormalitiesRadButton" runat="server" Text=" Abnormalities" OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/abnormalities.png" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceTherapeuticRadButton" runat="server" Text=" Therapeutic..." OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/therapeutic.png" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceSpecimensRadButton" runat="server" Text="Specimens" OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/specimen.png" />
                                    <br />
                                    <br />
                                    <telerik:RadButton ID="ByDistanceNotesRadButton" runat="server" Text="Notes" OnClientClicked="byDistanceSiteDetails" Skin="Office2007" Width="120" Icon-PrimaryIconUrl="~/Images/icons/notes.png" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <%--<asp:AsyncPostBackTrigger ControlID="Flip180Button" EventName="Click" />--%>
                    </Triggers>
                </asp:UpdatePanel>
            </div>

            <div style="height: 1px;"></div>
            <div id="PapillaryAnatomyButtonDiv" runat="server" style="vertical-align: bottom; display: none;">
                <div id="ERCPDiagramFooterDiv" style="margin-left: 5px;">
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td colspan="3">
                                <asp:CheckBox ID="PancreasDivisumCheckBox" runat="server" Text="Pancreas divisum present" AutoPostBack="true" />
                            </td>
                            <td align="center" rowspan="3">
                                <telerik:RadButton ID="PapillaryAnatomyButton" runat="server" Text="Papillary anatomy" Skin="Web20" OnClientClicked="openPapillaryAnatomyWindow" AutoPostBack="false" ButtonType="SkinnedButton" />
                            </td>
                        </tr>
                        <tr>
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
            <div style="height: 10px;"></div>

            <div id="UpperGIDiv" runat="server" style="vertical-align: bottom; margin-left: 115px; display: none;">
                <div id="UpperGIFooterDiv" style="margin-left: 10px;">
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:CheckBox ID="TransnasalCheckBox" runat="server" Text="<b>Procedure not carried out</b>" AutoPostBack="true" Visible=" false" />
                            </td>
                            <td>
                                <asp:CheckBox ID="CancelledProcCheckBox" runat="server" Text="<b>Transnasal endoscopy</b>" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="EUSDiv" runat="server" style="vertical-align: bottom; margin-left: 115px; display: none;">
                <div id="EUSFooterDiv" style="margin-left: 10px;">
                    <table width="100%" cellpadding="0" cellspacing="0">
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
                    <telerik:RadButton ID="ByDistanceButton" runat="server" ButtonType="SkinnedButton" OnClientClicked="SitesByDistance"
                        ToggleType="CustomToggle" AutoPostBack="false" Skin="Office2007">
                        <ToggleStates>
                            <telerik:RadButtonToggleState PrimaryIconUrl="~/images/icons/measurement.gif" Text="by Distance"></telerik:RadButtonToggleState>
                            <telerik:RadButtonToggleState PrimaryIconUrl="~/images/icons/colon.png" Text="by Diagram"></telerik:RadButtonToggleState>
                        </ToggleStates>
                    </telerik:RadButton>
                    <span style="padding-right: 96px;"></span>
                    <telerik:RadButton ID="ResectedColonButton" runat="server" Text="Resected colon" Skin="Office2007" ForeColor="#993333" AutoPostBack="false" OnClientClicked="openResectedColonWindow" Icon-PrimaryIconUrl="~/Images/icons/Resected.png" />
                </div>
            </div>
        </telerik:RadPane>
        <telerik:RadPane ID="DiagramButtonsRadPane" runat="server" CssClass="radPane">
            <div id="diagButtonsDiv" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                <telerik:RadButton ID="AddSiteButton" runat="server" Text="Add Site" Skin="WebBlue" Width="60px" AutoPostBack="false" />
                <telerik:RadButton ID="MarkAreaButton" runat="server" Text="Mark Area" Skin="WebBlue" Width="75px" />
                <telerik:RadButton ID="Flip180Button" runat="server" Text="Flip 180&#176;" Skin="WebBlue" Width="65px" Visible="false" />
                <telerik:RadButton ID="RemoveSiteButton" runat="server" Text="Remove" Skin="WebBlue" Width="60px" />
                <telerik:RadButton ID="PhotosButton" runat="server" Text="Photos" Skin="WebBlue" OnClientClicked="openPhotosWindow" AutoPostBack="false" Width="55px" />
                <!--  OnClientClicked="openPhotosWindow"-->
                <telerik:RadButton ID="ShowRegionsButton" runat="server" Text="Regions" Skin="WebBlue" Width="60px" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel2" runat="server" Skin="Metro" />
</asp:Content>

<asp:Content ID="IDBody" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <script type="text/javascript">
        var showRegionsButtonClientId = '#<%=ShowRegionsButton.ClientID%>';
        var positionLabelClientId = '<%=PositionLabel.ClientID%>';

        $(window).load(function () {
            SetByDistanceButtons(false);
        });

        //$('#rbToggleModality').click(function () {
        //    closeDialog();
        //});



        $(document).ready(function () {
            SetPhotoContextMenu();
            SetVideoContextMenu();
            SetDiagramContextMenu();
            //OGDPreviousGastricUlcer();
            var refreshTime = 10 * 60 * 1000; // in milliseconds, so 10 minutes
            window.setInterval(function () {
                $.ajax(
                    {
                        type: "POST",
                        url: "Default.aspx/KeepAlive",
                        dataType: "json",
                        contentType: "application/json; charset=utf-8"
                    })
            }, refreshTime);
        });

<%--        function DistanceAtValueChanged(sender, args) {
            var txtVal = sender.get_value();
            if (txtVal.trim == '' || txtVal <= 0 || txtVal > 9999) {
                $find("<%= ByDistanceAddRadButton.ClientID%>").set_enabled(false);
            } else {
                $find("<%= ByDistanceAddRadButton.ClientID%>").set_enabled(true);
            }
        }

        //$(document).ajaxComplete(function () {
        //    SetPhotoContextMenu();
        //});
        //function SessionRefresh() {
        //    ContinueSession();
        //   // var notification = $find("ctl00_SessionTimeoutNotification");
        //}
--%>
        function ByDistanceAddClicked(button, args) {
            var txtVal = $find("<%= ByDistanceAtTextBox.ClientID%>").get_value();
            if (txtVal.trim == '' || txtVal <= 0 || txtVal > 9999) {
                alert('Please enter a valid distance.');
            } else {
                SetByDistanceButtons(false);
            }
        }


        function ByDistanceDeleteSite(button, args) {
            var message = "Are you sure you want to remove this site and all associated data if any?";
            if (confirm(message)) {
                button.click();
            } else {
                args.set_cancel(true);
            }
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
            $find("<%= ByDistanceAbnormalitiesRadButton.ClientID%>").set_enabled(val);
            $find("<%= ByDistanceTherapeuticRadButton.ClientID%>").set_enabled(val);
            $find("<%= ByDistanceSpecimensRadButton.ClientID%>").set_enabled(val);
            $find("<%= ByDistanceNotesRadButton.ClientID%>").set_enabled(val);
        }

        //Open byDistance Site Details RadWindow (Col & Sig only)
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

        //Open the Site Details RadWindow
        function OpenSiteDetails(region, siteId, optionChosen, insertionType, areaNo) {
            var currentSiteId = siteId;
            //alert('currentSiteId: ' + currentSiteId);
            var obj = {};
            obj.siteId = parseInt(currentSiteId);
            
            //alert('obj.siteId: ' + obj.siteId);

            $.ajax({
                type: "POST",
                url: "PatientProcedure.aspx/IsLymphNodeBySiteId",
                dataType: "json",
                data: JSON.stringify(obj),
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    if (data.d === 'True') {
                        console.log('PatientProcedure.aspx: line 746 - ' + response.d);
                        //alert('success');
                    } else {
                        console.log('PatientProcedure.aspx: line 746 - ' + response.d);
                    }
                },
                error: function(xhr, ajaxOptions, thrownError) {
                    alert(xhr.status);
                    alert(thrownError);
                }
            });

            //Get a reference to the window.
            var oWnd = $find("<%= SiteDetailsRadWindow.ClientID %>");
            var url = "";
            if (typeof insertionType == 'undefined') insertionType = "";

            if (optionChosen == "Attach Photos") {
                //C.S - added a blank check when assigning the telerik ctrl to another 
                //variable as it was blowing out when no scopes selected and stopping the alert from popping.
                var ddl1stScope = $find("<%= cboInstrument1.ClientID %>");
                var ddl2ndScope = $find("<%= cboInstrument2.ClientID %>");
                if (ddl1stScope != '') {
                    var val1stScope = ddl1stScope.get_selectedItem().get_text();
                } else if (ddl2ndScope != '') {
                    var val2ndScope = ddl2ndScope.get_selectedItem().get_text();
                }
                //changed to OR from && so it works with procedures with only 1 scope.
                if (val1stScope === '' || val2ndScope === '') {
                    alert("Before you can allocate images you need to specify the instrument(s) used in this procedure.");
                    return;
                } else {
                    url = "<%= ResolveUrl("~/Products/Common/Photos.aspx") %>";
                    url = url + "?SiteId={0}";
                    url = url.replace("{0}", siteId);
                }
            }
            else {
                /* So, once the user has made a selection- he will be taken to another Page- which will be under the Rad Dialogue Box... Go to   [SiteDetails.aspx] to see what Happens! Comment: Shawkat;  */
                url = "SiteDetails.aspx?Region={0}&SiteId={1}&OptionChosen={2}&InsertionType={3}&AreaNo={4}";
                url = url.replace("{0}", region);
                url = url.replace("{1}", siteId);
                url = url.replace("{2}", optionChosen);
                url = url.replace("{3}", insertionType);
                url = url.replace("{4}", areaNo);
                oWnd.SetSize(955, 700);
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

        function openDiagnosesWindow() {
            var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
            var url = "<%= ResolveUrl("~/products/gastro/abnormalities/common/diagnoses.aspx") %>";

            if (['2', '7'].indexOf(selectedProcType) >= 0) {   //ERCP, EUS (HPB)
                oWnd2.SetSize(730, 680);
            } else {
                oWnd2.SetSize(730, 680);
            }

            oWnd2._navigateUrl = url
            //Add the name of the function to be executed when RadWindow is closed.
            oWnd2.add_close(OnClientClose);
            oWnd2.show();
        }

        function openPhotosWindow() {
            var ddl1stScope = $find("<%= cboInstrument1.ClientID %>");
            var val1stScope = ddl1stScope.get_selectedItem().get_text();
            var ddl2ndScope = $find("<%= cboInstrument2.ClientID %>");
            var val2ndScope = ddl2ndScope.get_selectedItem().get_text();

            if (val1stScope === '' && val2ndScope === '') {
                alert("Before you can allocate images you need to specify the instrument(s) used in this procedure.");
                return;
            } else {
                var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
                var url = "<%= ResolveUrl("~/Products/Common/Photos.aspx") %>";
                oWnd2._navigateUrl = url
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
                oWnd2.set_behaviors(Telerik.Web.UI.WindowBehaviors.Close);
                oWnd2.maximize();
            }

        }

        function openMovePhotoWindow(photo) {
            var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
            var url = "<%= ResolveUrl("~/Products/Common/PhotoMove.aspx?PhotoId={0}&IsVideo=false")%>";
            url = url.replace("{0}", GetPhotoId(photo));
            oWnd2.SetSize(500, 200);
            oWnd2._navigateUrl = url
            //Add the name of the function to be executed when RadWindow is closed.
            oWnd2.add_close(OnClientClose);
            oWnd2.show();
        }

        function openMoveVideoWindow(video) {
            var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
            var url = "<%= ResolveUrl("~/Products/Common/PhotoMove.aspx?PhotoId={0}&IsVideo=true")%>";
            url = url.replace("{0}", GetVideoId(video));
            oWnd2.SetSize(500, 200);
            oWnd2._navigateUrl = url
            //Add the name of the function to be executed when RadWindow is closed.
            oWnd2.add_close(OnClientClose);
            oWnd2.show();
        }

        function openPapillaryAnatomyWindow() {
            var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
            var url = "<%= ResolveUrl("~/Products/Common/PapillaryAnatomy.aspx") %>";
            oWnd2.SetSize(700, 450);
            oWnd2._navigateUrl = url
            //Add the name of the function to be executed when RadWindow is closed.
            oWnd2.add_close(OnClientClose);
            oWnd2.show();
        }

        function OnClientClose(oWnd, eventArgs) {
            //Remove the OnClientClose function to avoid
            //adding it for a second time when the window is shown again.
            oWnd.remove_close(OnClientClose);

            RefreshSiteSummary();
            //SetPhotoContextMenu();
        }

        function OnPhotoWindowClose(oWnd, eventArgs) {
            oWnd.remove_close(OnPhotoWindowClose);

            RefreshPhotos();
        }

        function RefreshDNASummary() {
            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest("dna");
            //SetPhotoContextMenu();
        }

        function RefreshSiteSummary() {
            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest("content");
            //SetPhotoContextMenu();
        }

        function RefreshPhotos() {
            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest("photo");
            //SetPhotoContextMenu();
        }

        function ShowErrorNotification(errorMessage) {
            var notification = $find("<%= ErrorNotification.ClientID%>");
            notification.set_text(errorMessage);
            notification.show();
        }

        function DetachPhoto(photo) {
            var reqArgument = "DetachPhoto" + "#" + GetPhotoId(photo);
            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest(reqArgument);
        }

        function DetachVideo(video) {
            var reqArgument = "DetachPhoto" + "#" + GetVideoId(video);
            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest(reqArgument);
        }

        function SetPhotoContextMenu() {
            $(".rigThumbnailsBox img").PhotoContextMenu({
                menu: 'PhotoRightClickMenu',
                onShow: onPhotoContextMenuShow,
                onSelect: onPhotoContextMenuItemSelect
            });
        }

        function SetVideoContextMenu() {
            $(".imageWrapper").VideoContextMenu({
                menu: 'VideoRightClickMenu',
                onShow: onVideoContextMenuShow,
                onSelect: onVideoContextMenuItemSelect
            });
        }

        function SetDiagramContextMenu() {
            if (['2', '7'].indexOf(selectedProcType) < 0) { return; } //Display diagnoses menu for ERCP, EUS (HPB) only.

            $([diagram.node]).DiagramContextMenu({
                menu: 'DiagramClickMenu',
                onShow: onDiagramContextMenuShow,
                onSelect: onDiagramContextMenuItemSelect

            });
        }

        function GetPhotoId(photo) {
            var ImageClientId = photo.attr("id");
            var ImageLIElement = photo.closest("li");

            var ImageGalleryClientId = photo.closest('div[class^="RadImageGallery RadImageGallery_Default"]')[0].id;
            var photoIndex = $("#" + ImageGalleryClientId + " li").index(ImageLIElement);

            var items = $find(ImageGalleryClientId).get_items();
            var photoId = items.getItem(photoIndex).get_description();
            return photoId;

            var reqArgument = "DetachPhoto" + "#" + photoId;
        }

        function GetVideoId(video) {
            var photoId = video.find("span[id$='PhotoIdLabel']").text();
            return photoId;
        }

        function openResectedColonWindow() {
            var oWnd = $find("<%= ResectedColonWindow.ClientID %>");
            oWnd.add_close(OnClientClose);
            oWnd.show();
        }

        function CloseResectedColonWindow() {
            var oWnd = $find("<%= ResectedColonWindow.ClientID%>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }
        function closeDialog() {
            $find("<%=MessageRadWindow.ClientID%>").close();
        }

        function closeDialogImagePort() {
            $find("<%=ImagesExistRadWindow.ClientID%>").close();
        }

        function closeDialogDeleteProc() {
            $find("<%=DeleteProcRadWindow.ClientID%>").close();
        }

        function DisplayDeleteProcMessage() {
            var oWnd = $find("<%=DeleteProcRadWindow.ClientID%>");
            $('#<%= lblDeleteMessage.ClientID%>').html("What do you want to happen?");//("Report INCOMPLETE <br />-------------------------<br /> Clicking DELETE will delete this report. <br />Cancel to return to the home page.<br /><br />");
            oWnd.show();
            return false;
        }

        var lightBox;
        function lightBoxLoad(sender, args) {
            lightBox = sender;
        }

        function showLightBox(index) {
            lightBox.set_currentItemIndex(index);
            lightBox.show();
        }

        function lightBoxShowed(sender, args) {
            args.set_cancel(true);
        }
    </script>

    <telerik:RadNotification ID="ErrorNotification" runat="server" VisibleOnPageLoad="false"
        Skin="Metro" BorderColor="Red" AutoCloseDelay="0" BorderStyle="Ridge" Animation="None" EnableRoundedCorners="true" EnableShadow="true"
        Title="" Width="400" Height="0" TitleIcon="None" ContentIcon="Warning" Position="Center" ShowCloseButton="true" />

    <telerik:RadWindowManager ID="PatientProcedureRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="radWindow" runat="server" />
        </Windows>
        <Windows>
            <telerik:RadWindow ID="SiteDetailsRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="950px" Height="600px" VisibleStatusbar="false" Behaviors="Move" />
            <telerik:RadWindow ID="PhotosRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="850px" Height="750px" VisibleStatusbar="false" />
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
            <telerik:RadWindow ID="ImagesExistRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="250px" VisibleStatusbar="false" VisibleOnPageLoad="false" Visible="false" Title="ImagePort Images" BackColor="#ffffcc">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                <img id="Img2" runat="server" src="~/Images/info-32x32.png" />
                            </td>
                            <td style="text-align: center; padding: 20px;">
                                <asp:Label ID="lblImageExistsMessage" runat="server" Font-Size="Large" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="padding: 10px; text-align: center;">
                                <telerik:RadButton ID="RemoveImages" runat="server" Text="Yes" Skin="Windows7" ButtonType="SkinnedButton" OnClientClicked="closeDialogImagePort" Width="100" Height="30" Font-Size="Large" />
                                <telerik:RadButton ID="KeepImages" runat="server" AutoPostBack="false" Text="No" Skin="Windows7" ButtonType="SkinnedButton" OnClientClicked="closeDialogImagePort" Width="100" Height="30" Font-Size="Large" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </telerik:RadWindow>
            <telerik:RadWindow ID="DeleteProcRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="200px" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Report Incomplete" BackColor="#ffffcc">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                <img id="Img1" runat="server" src="~/Images/info-32x32.png" />
                            </td>
                            <td style="text-align: center; padding: 20px;">
                                <asp:Label ID="lblDeleteMessage" runat="server" Font-Size="Large" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="padding: 10px; text-align: center; padding-top: 30px !important;">
                                <telerik:RadButton ID="DeleteProcRadButton" runat="server" Text="Delete this report" Skin="Windows7" ForeColor="#cc3300" ButtonType="SkinnedButton" Font-Size="Large" Style="margin-right: 20px;" />
                                <telerik:RadButton ID="KeepProcRadButton" runat="server" Text="Keep this report" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" Style="margin-right: 20px;" OnClientClicked="closeDialogDeleteProc" />
                                <telerik:RadButton ID="CancelDeleteRadButton" runat="server" Text="Cancel" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeDialogDeleteProc" Font-Size="Large" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>

    <asp:ObjectDataSource ID="SummaryPremedObjectDataSource" runat="server" SelectMethod="GetPremedReportSummary" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="SummaryObjectDataSource" runat="server" SelectMethod="GetReportSummary" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="SitesWithPhotosObjectDataSource" runat="server" SelectMethod="GetSitesWithPhotos" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>

    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Height="100%" BorderWidth="1" Orientation="Horizontal" Skin="Windows7">
        <telerik:RadPane ID="RadPane2" runat="server" CssClass="radPane" Height="100px" Scrolling="None">
            <unisoft:PatientDetails runat="server" ID="PatientDetails" />
        </telerik:RadPane>
        <telerik:RadPane ID="BottomRadPane" runat="server" Scrolling="None" Height="568px">
            <telerik:RadSplitter ID="radReportPage" runat="server" Orientation="Horizontal" Skin="Windows7">
                <telerik:RadPane ID="radContentPane" runat="server" Height="534px" MaxHeight="534" EnableViewState="false">
                    <%--<div>
                        <telerik:RadMenu ID="UnisoftMenu" runat="server" Skin="Metro" Width="100%" EnableShadows="true" ClickToOpen="false" Style="z-index: 1;" />
                    </div>--%>
                    <div class="text" style="height: 25px;">
                        <div style="float: left;" runat="server" ondblclick="DisplayProcedureInfo()">
                            <asp:Label ID="lblProcDate" runat="server" Text="" />&nbsp;
                          
                        </div>
                        <div style="float: right; padding-right: 10px;">
                            <div class="DNACheckBoxDiv">
                                <asp:CheckBox ID="ProcNotCarriedOutCheckBox" runat="server" Text="Procedure not carried out" AutoPostBack="false" />
                            </div>
                        </div>

                    </div>
                    <%--  <div runat="server" id="alertDiv" style="border:solid; border-color:red; height:auto; text-align:left; width:auto; display:none" >
                         <img ID="AlertImage" runat="server"  src="~/Images/warning-32x32.png" style="vertical-align:middle; padding-left :2px; padding-right :2px"  /> 
                         <label id="NpsaAlertLabel" runat="server" style="word-wrap: break-word"></label>                                                                                        
                         </div>--%>
                    <div style="margin-left: 15px; width: 70%;">
                        <p>
                            <asp:Label ID="ProcedureNotCarriedOutLabel" runat="server" CssClass="rptSummaryText12" />
                        </p>
                        <asp:ListView ID="SummaryPremedListView" runat="server" DataSourceID="SummaryPremedObjectDataSource">
                            <LayoutTemplate>
                                <table id="itemPlaceholderContainer1" runat="server" border="0" class="rptSummaryText12" cellspacing="0" cellpadding="0">
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr>
                                    <th align="left">
                                        <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" />
                                    </th>
                                </tr>
                                <tr>
                                    <td style="padding-left: 5px;">
                                        <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary") %>' />
                                    </td>
                                </tr>
                                <tr style="height: 10px">
                                    <td></td>
                                </tr>
                            </ItemTemplate>
                        </asp:ListView>
                        <asp:ListView ID="SummaryListView" runat="server" DataSourceID="SummaryObjectDataSource">
                            <LayoutTemplate>
                                <table id="itemPlaceholderContainer" runat="server" border="0" class="rptSummaryText12" cellspacing="0" cellpadding="0">
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr>
                                    <th align="left">
                                        <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" />
                                    </th>
                                </tr>
                                <tr>
                                    <td style="padding-left: 5px;">
                                        <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary") %>' />
                                    </td>
                                </tr>
                                <tr style="height: 10px">
                                    <td></td>
                                </tr>
                            </ItemTemplate>
                        </asp:ListView>

                        <asp:ListView ID="PhotosListView" runat="server" DataSourceID="SitesWithPhotosObjectDataSource" DataKeyNames="SiteId">
                            <LayoutTemplate>
                                <div class="rptSummaryText12" style="color: #0072c6"><b>Photos</b></div>
                                <table id="itemPlaceholderContainer" runat="server" border="0" cellspacing="0" cellpadding="0" class="rptSummaryText12">
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr runat="server">
                                    <th align="left" style="padding-left: 5px; color: #606060;" runat="server">
                                        <b>
                                            <asp:Label ID="SiteNameLabel" runat="server" Text='<%#Eval("SiteName")%>' /></b>
                                    </th>
                                </tr>
                                <tr runat="server">
                                    <td style="padding-left: 5px;" runat="server">
                                        <telerik:RadImageGallery ID="PhotosImageGallery" runat="server" ZIndex="100000"
                                            DataImageField="ImageUrl" DataThumbnailField="ImageThumbnailUrl" DataTitleField="SiteDescription"
                                            BackColor="Transparent" DisplayAreaMode="LightBox"
                                            OnNeedDataSource="PhotosImageGallery_NeedDataSource"
                                            OnItemDataBound="PhotosImageGallery_OnItemDataBound" Width="600">
                                            <ImageAreaSettings Height="400px" ResizeMode="Fit" />
                                            <ThumbnailsAreaSettings ThumbnailsSpacing="4px" ThumbnailHeight="70" ThumbnailWidth="90"
                                                Width="474" Height="78" ShowScrollButtons="true" />
                                            <%--90*5 + 4*6 = 474--%>
                                        </telerik:RadImageGallery>
                                    </td>
                                </tr>
                                <tr>
                                    <td></td>
                                </tr>
                                <tr style="height: 10px">
                                    <td></td>
                                </tr>
                            </ItemTemplate>
                        </asp:ListView>

                        <div class="demo-container size-custom">
                            <telerik:RadListView ID="VideosListView" runat="server" OnNeedDataSource="VideosListView_NeedDataSource">
                                <LayoutTemplate>
                                    <div class="rptSummaryText12" style="color: #0072c6"><b>Videos</b></div>
                                    <table id="itemPlaceholderContainer" runat="server" border="0" cellspacing="0" cellpadding="0" class="rptSummaryText12">
                                        <tr id="itemPlaceholder" runat="server">
                                        </tr>
                                    </table>
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <tr runat="server">
                                        <td style="padding-left: 5px;" runat="server">
                                            <div class="imageWrapper" onclick='<%# "showLightBox("& Container.DisplayIndex &"); return false;" %>'>
                                                <span class="thumbnailHolder">
                                                    <asp:Image ID="ThumbnailImage" runat="server" Height="109px" Width="194px" AlternateText="Video Thumbnail" ImageUrl='<%# Eval("ImageThumbnailUrl") %>' />
                                                    <span class="playIcon"></span>
                                                </span>
                                                <asp:Label ID="SiteDescriptionLabel" runat="server" Text='<%#  Eval("SiteDescription") %>'></asp:Label>
                                                <asp:Label ID="PhotoIdLabel" runat="server" Text='<%#  Eval("PhotoId") %>' Style="display: none;"></asp:Label>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </telerik:RadListView>

                            <telerik:RadLightBox RenderMode="Lightweight" ID="VideosLightBox" runat="server" Modal="true" PreserveCurrentItemTemplates="true"
                                ItemsCounterFormatString="Video {0} of {1}" Width="720px" Height="340px">
                                <ClientSettings>
                                    <ClientEvents OnLoad="lightBoxLoad" />
                                </ClientSettings>
                            </telerik:RadLightBox>

                        </div>

                    </div>
                </telerik:RadPane>
                <telerik:RadPane runat="server" Scrolling="None" CssClass="radPane">
                    <unisoft:procedurefooter runat="server" ID="procedurefooter" />
                </telerik:RadPane>
            </telerik:RadSplitter>
        </telerik:RadPane>

    </telerik:RadSplitter>


    <ul id="AddSiteMenu" class="contextMenu">
        <li><a href="">Anterior</a></li>
        <li><a href="">Posterior</a></li>
        <li><a href="">Both / Either</a></li>
    </ul>

    <%--    <ul id="DiagramClickMenu" class="contextMenu">
        <li><a href="" style="background-image: url(../Images/icons/diagnoses.png)">Diagnoses</a></li>
    </ul>--%>

    <ul id="SiteClickMenu" class="contextMenu">
        <li><a submenu="AbnormalitiesSubMenu" href="" style="background-image: url(../Images/icons/abnormalities.png)">Abnormalities</a></li>
        <li><a href="" style="background-image: url(../Images/icons/therapeutic.png)">Therapeutic Procedures</a></li>
        <li><a submenu="SpecimensSubMenu" href="" style="background-image: url(../Images/icons/specimen.png)">Specimens</a></li>
        <%--<li id="liDiagnoses" runat="server" visible="false"><a href="" style="background-image: url(../Images/icons/diagnoses.png)">Diagnoses</a></li>--%>
        <li><a href="" style="background-image: url(../Images/icons/notes.png)">Additional notes</a></li>
        <li class="separator"></li>
        <li><a href="" style="background-image: url(../Images/icons/camera.png)">Attach Photos</a></li>
        <li class="separator"></li>
        <li><a href="" style="background-image: url(../Images/icons/cancel.png)">Remove Site</a></li>
        <li class="separator"></li>
        <li><a radio="AntPos" href="">Anterior</a></li>
        <li><a radio="AntPos" href="">Posterior</a></li>
        <li><a radio="AntPos" href="">Both / Either</a></li>
    </ul>

    <ul id="PhotoRightClickMenu" class="contextMenu">
        <li><a href="" style="background-image: url(../Images/icons/move_site.png)">Move photo to a different site </a></li>
        <li><a href="" style="background-image: url(../Images/icons/detach.png)">Detach photo</a></li>
    </ul>

    <ul id="VideoRightClickMenu" class="contextMenu">
        <li><a href="" style="background-image: url(../Images/icons/move_site.png)">Move video to a different site </a></li>
        <li><a href="" style="background-image: url(../Images/icons/detach.png)">Detach video</a></li>
    </ul>

    <ul id="AbnormalitiesSubMenu" class="contextMenu">
        <li><a href="">Gastritis</a></li>
        <li><a href="">Stomach Ulcer</a></li>
        <li><a href="">Lumen</a></li>
    </ul>

    <ul id="SpecimensSubMenu" class="contextMenu">
        <li><a href="">Test1</a></li>
        <li><a href="">Test2</a></li>
        <li><a href="">Test3</a></li>
    </ul>

    <telerik:RadWindowManager ID="ResectedColonWindowManager" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
        <Windows>
            <telerik:RadWindow ID="ResectedColonWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="840px" Height="580px" Title="Resected Colons" VisibleStatusbar="false" Animation="None">
                <ContentTemplate>
                    <div id="tempDiv" style="display: none"></div>
                    <table cellspacing="15">
                        <tr>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="IntactColonCanvas" style="display: none;"></canvas>
                                    <img id="IntactColonImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center; vertical-align: bottom;">Intact Colon</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="AbdominoPerinealCanvas" style="display: none;"></canvas>
                                    <img id="AbdominoPerinealImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Abdomino-perineal resection</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="LowAnteriorCanvas" style="display: none;"></canvas>
                                    <img id="LowAnteriorImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Low anterior resection</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="SigmoidColectomyCanvas" style="display: none;"></canvas>
                                    <img id="SigmoidColectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Sigmoid colectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="HighAnteriorCanvas" style="display: none;"></canvas>
                                    <img id="HighAnteriorImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">High anterior</div>
                            </td>
                        </tr>
                        <tr>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="HartmannsProcedureCanvas" style="display: none;"></canvas>
                                    <img id="HartmannsProcedureImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Hartmann's procedure</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="LeftHemicolectomyCanvas" style="display: none;"></canvas>
                                    <img id="LeftHemicolectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Left hemicolectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="TransverseColectomyCanvas" style="display: none;"></canvas>
                                    <img id="TransverseColectomyCanvasImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Transverse colectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="RightHemicolectomyCanvas" style="display: none;"></canvas>
                                    <img id="RightHemicolectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Right hemicolectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="ExtendedRightHemicolectomyCanvas" style="display: none;"></canvas>
                                    <img id="ExtendedRightHemicolectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Extended right hemicolectomy</div>
                            </td>
                        </tr>
                        <tr>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="SubtotalColectomyCanvas" style="display: none;"></canvas>
                                    <img id="SubtotalColectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center; vertical-align: middle;">Subtotal colectomy with ileorectal anastomosis</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="SubtotalColectomyStumpCanvas" style="display: none;"></canvas>
                                    <img id="SubtotalColectomyStumpImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Subtotal colectomy, ileostomy & rectal stump</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="TotalColectomyCanvas" style="display: none;"></canvas>
                                    <img id="TotalColectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Total colectomy plus ileal pouch</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="PanProctoColectomyCanvas" style="display: none;"></canvas>
                                    <img id="PanProctoColectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Pan procto colectomy</div>
                            </td>
                            <td class="bgResectedColons">
                                <div style="background-color: white;">
                                    <canvas id="IleocaecectomyCanvas" style="display: none;"></canvas>
                                    <img id="IleocaecectomyImg" alt="" height="100" width="100" />
                                </div>
                                <div class="txtResectedColons" style="align-self: center">Ileocaecectomy</div>
                            </td>
                        </tr>
                    </table>

                    <div id="buttonsdiv" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central; text-align: center;">
                        <telerik:RadButton ID="CloseResectedButton" runat="server" Text=" Close " Skin="Web20" AutoPostBack="false" OnClientClicked="CloseResectedColonWindow" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
            <telerik:RadWindow ID="ProcNotCarriedOutRadWindow" Modal="true" runat="server" Title="Procedure NOT carried out"
                KeepInScreenBounds="true" Width="500px" Height="350px" VisibleStatusbar="false" ShowContentDuringLoad="false" Skin="Metro">
                <ContentTemplate>
                    <div class="abnorHeader">Reason the procedure was NOT carried out:</div>
                    <div style="padding: 1em; margin-bottom: 1em;" id="ProcNotCarriedOutRadWindowDiv">
                        <div style="width: 90%; padding: 1em; border: 1px solid black; border-radius: 0px; margin: 1em; box-sizing: content-box;">
                            <label />
                            <asp:RadioButtonList ID="ProcNotCarriedOutRadioButtonList" runat="server">
                                <asp:ListItem Value="1" Text="Patient DNA" />
                                <asp:ListItem Value="2" Text="Patient cancelled" />
                                <asp:ListItem Value="3" Text="Hospital cancelled" />
                            </asp:RadioButtonList>

                            <input type="checkbox" id="chkPatientDNA_Text" name="chkPatientDNA_Text" value="combine" style="display: none; margin-top: 10px;">
                            <label for="chkPatientDNA_Text" id="lblDNA_PP_Text"></label>
                        </div>

                        <p class="">
                            Please record the indications and enter in to the Follow up screen why the Procedure was not carried out.
                        </p>
                        <div id="divProcNotcarriedOutButtons" class="" style="height: auto; text-align: center">
                            <telerik:RadButton ID="btnProcNotcarriedOutSubmit" runat="server" Text="Save" Skin="Web20" AutoPostBack="false" OnClientClicked="ProcNotCarriedOut_UpdateSelection" Icon-PrimaryIconCssClass="telerikOkButton" ClientIDMode="Static" />
                            &nbsp;
                                                            <telerik:RadButton ID="btnProcNotCariedOutCancel" runat="server" Text="Cancel" Skin="Web20" AutoPostBack="false" OnClientClicked="ProcNotCarriedOutCloseDialogueBox" Icon-PrimaryIconCssClass="telerikCancelButton" />
                        </div>
                        <asp:HiddenField runat="server" ID="selectedProcedureId" Value="123" ClientIDMode="Static" />
                        <asp:HiddenField runat="server" ID="selectedProcedureType" Value="UPPERGI, PROCT" ClientIDMode="Static" />
                        <asp:HiddenField runat="server" ID="selectedNodeText" Value="123" ClientIDMode="Static" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>

</asp:Content>
