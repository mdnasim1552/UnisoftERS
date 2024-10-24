<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="patientview.ascx.vb" Inherits="UnisoftERS.patientview" ClassName="patientview" %>

<%@ Register Src="~/UserControls/PrintInitiate.ascx" TagPrefix="unisoft" TagName="PrintInitiate" %>
<%@ Register Src="~/UserControls/PathologyResults.ascx" TagPrefix="unisoft" TagName="PathologyResults" %>
<%@ Register Src="~/Procedure Modules/CoMorbidity.ascx" TagName="CoMorbidity" TagPrefix="PreProc" %>
<%--<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit"%>--%>
<script type="text/javascript" src="../Scripts/pdf-import-scripts.js"></script>
<style>
    .forceMetroSkin {
        color: #333;
        font-family: "Segoe UI",Arial, Helvetica, sans-serif;
        font-size: 12px;
    }

    .hairlinehr {
        height: 0px;
        border: none;
        border-top: 1px solid gray;
    }

    .reportheader {
        color: #0072c6;
        font-weight: bold;
    }

    .divboxshadow {
        padding: 20px;
        box-shadow: inset 0 -3em 3em rgba(0,0,0,0.1), 0 0 0 2px rgb(255,255,255), 0.3em 0.3em 1em rgba(0,0,0,0.3);
    }

    .hrnormal {
        border: none;
        height: 1px;
        color: #333;
        background-color: #333;
    }

    .hrdotted {
        border: 1px dotted #0094ff;
    }

    tr, th, td {
        vertical-align: top !important;
        color: #333;
        font-family: "Segoe UI",Arial, Helvetica, sans-serif;
        font-size: 12px;
    }

    h2, h3 {
        color: navy;
    }

    .ui-menu .ui-menu-item div, .ui-menu-item div:hover {
        color: #000 !important;
        border-radius: 0px !important;
        border: none;
        font-family: inherit;
        font-size: 12px !important;
        font-weight: normal;
        padding: 5px;
    }

    .hidden {
        display: none;
    }

    .rigThumbnailsBox {
        background-color: white !important;
        margin-left: 5px;
        margin-top: 5px;
    }

    .left {
        float: left;
    }

    .border_bottom {
        border-bottom: 1pt dashed #B8CBDE;
    }

    .rdChecked {
        box-shadow: 0 0 5px #5cd053;
        border-color: #28921f;
    }

    .UGI_Procedure {
        color: red;
        /*background-color:#ffb8b8; goldenrod;*/
    }

    .LockedProcedure {
        color: #990033;
    }

    .ProcedureIncomplete {
        color: #1E90FF;
    }
    .procedureLocked{
        color:#aeafb1;
    }

    .rltbActiveImage {
        height: 400px !important;
    }

    .rltbDescription {
        display: none;
    }

    .rigItemBox {
        margin-left: 50px;
        margin-top: -30px;
        /*background-color:white;*/
        height: 400px !important;
    }

    .ImageWrapper {
        font-family: "Segoe UI", Arial, Helvetica, sans-serif;
        font-size: 12px;
        line-height: normal;
        color: black;
    }

    .ImageFooter {
        background-color: #C4D2D9;
        height: 40px;
        line-height: 40px;
        font-family: "Segoe UI", Arial, Helvetica, sans-serif;
        font-size: 14px;
        color: black;
    }

    .TextOverImage {
        position: absolute;
        color: white;
        background-color: rgb(169, 169, 169);
        background-color: rgba(169, 169, 169, 0.66);
        top: 0px;
        left: 3px;
        border-radius: 0 0 5px 0;
        cursor: default;
        width: 18%;
        text-align: center;
    }

    .DescriptionBox {
        margin-left: 20px;
        border: 1px solid #98abbe;
        border: 1px solid #98abbe;
        /*float:left;*/
    }

    .rbAdd24 {
        background-position: 0 -18px !important;
    }

    .MainThumbnailRotator div.rrClipRegion {
        /* The following style removes the border of the rotator that is applied to the items wrapper DIV of the control by default, in case the control renders buttons. 
    border: 0 none;*/
        border: 1px solid #d9d9d9;
    }

    .ThumbnailSlider {
        padding: 2px 5px;
        background-color: #f2f2f2;
        border: 1px solid #d9d9d9;
        margin: 5px 5px;
        /*border-radius: 25px;*/
    }

    .cssItem {
    }

    .RadRotator {
        /*background-color: #C4D2D9;*/
    }

    .rrClipRegion {
        /*background-color: #C4D2D9 !important;*/
    }

    .rrItemsList {
        /*border: none !important;
        background-color: #C4D2D9;
        margin-left: 0px !important;*/
    }

        .rrItemsList li {
            /*background-color: #C4D2D9 !important;*/
        }

        .rrItemsList img {
            opacity: 1 !important;
            border-radius: 10px;
        }

        .rrItemsList a:hover img {
            opacity: 1 !important;
        }

    .rrItem {
        margin: 4px;
        border: none;
    }

        .rrItem img {
            border-radius: 0px 10px 0px 10px;
            cursor: pointer;
        }

    .cssSelectedItem {
    }

        .cssSelectedItem img {
            border: 3px solid green;
        }

    .rmpSubtitlesButton {
        display: none;
    }

    .rmpShareButton {
        display: none;
    }

    .rmpHDButton {
        display: none;
    }

    /*overrides the mess created by the dafault pages tabstrips render mode */
    .prev-procs-page .RadTabStrip .rtsLink {
        padding: 0 0 0 9px;
        border: none;
    }

    .tab-page-button {
        color: #333 !important;
        font: 12px/26px "Segoe UI", Arial, Helvetica, sans-serif;
        text-decoration: none !important;
        padding: 9px;
        border: 1px solid #CECECE;
        background-color: #FFFFFF;
        background-image: linear-gradient(#fff, #E6E6E6);
        border-top-left-radius: 3px;
        border-top-right-radius: 3px;
        white-space: nowrap;
        cursor: pointer;
    }

    .selected-tab-button {
        background-image: none;
        font-weight: 100;
        cursor: default !important;
    }

    /* set width of RadMultiColumnComboBox "ConsultantComboBox" */
    .k-dropdown-wrap .k-input {
        width: 240px !important;
    }

    .open-file-upload-button span.rbPrimaryIcon {
        border-left: 2px solid #7eb3bc;
        background-color: #e7e7e7;
        margin: -2px 0 0 -14px;
        width: 20px;
        padding: 5px 17px 4px 7px;
        background-position: center;
    }

    .RadPicker_Default .rcCalPopup {
        margin-left: 0%;
    }


    .RadUpload, .RadUploadProgressArea {
        align-content: center !important
    }

    .RadUpload, .RadUploadProgressArea {
        align-content: center !important
    }

    /* Mahfuz changed on 16 Mar 2021*/
    .RadForm_Metro.rfdTextbox input[type="text"].rfdDecorated {
        border: 0 solid !important;
        border-radius: 0 !important;
        height: 20px;
    }

    .k-dropdown-wrap {
        text-align: right !important;
    }

    .RadMultiColumnComboBox_Metro .k-dropdown-wrap {
        border-radius: 0 !important;
        height: 25px;
    }


    #RemoveProcedureTypeLabel {
        border-color: none;
    }

    /*#RadWindow_ContentTemplate {
        align-content: center;        
    }*/
    #RadWindow_ContentTemplate .rwIcon {
        height: 0 !important;
        width: 0 !important;
        display: none !important;
    }

    .rwIcon {
        display: none !important;
    }

    .procedure-referrer td {
        text-align: left;
        padding-right: 5px;
    }

    .treeListAutoWidthHeight{
        width: auto !important;
        height: calc(75vh - 50px) !important
    }

    .treeViewAutoWidthHeight{
        width: 270px !important;
        height: calc(70vh - 20px) !important
    }
    @media (min-height: 750px) {
        .new_preassessment {
            overflow-y: auto;
            height: 765px;
            width: 100% !important;
            overflow-x: hidden;
        }
    }
@media (max-height: 750px) {
    .new_preassessment {
        height: 550px;
        overflow-y: auto;
        width: 92% !important;
        overflow-x: hidden;
    }
    .question-top
    {
        margin-top: 15px;
    }
  .assessment-question-option {
    margin-left: 10px !important;  /* Use !important as a last resort */
}

}
  @media (min-height: 750px) {
        .preAssessBtn {
            text-align: left;
            width: 1349px !important;
            border-top: 1px dashed #B8CBDE;
            margin-left: 10px;
            margin-left: 26px;
            padding-top: 10px;
        }
    }
        @media (max-height: 750px) {
        .preAssessBtn {
            text-align: left;
            width: 949px !important;
            border-top: 1px dashed #B8CBDE;
            margin-left: 10px;
            margin-left: 26px;
            padding-top: 10px;
        }
    }
   .margin-com
    {
        margin-left: 8px !important;
    }
    .other-pad
    {
        margin-left: 6px;
    }
    .margin-com
    {
        margin-top: 8px !important;
    }
    #ValidationNotification {
        top: 45% !important; 
        left:38% !important;
    }
</style>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="decorationZone" Skin="Metro" />
<telerik:RadNotification ID="CreateProcRadNotifier" runat="server" Animation="Fade"
    EnableRoundedCorners="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following </div>"
    TitleIcon="delete" Position="Center" LoadContentOn="PageLoad"
    AutoCloseDelay="7000">
    <ContentTemplate>
        <div id="createValDiv" class="aspxValidationSummary"></div>
    </ContentTemplate>
</telerik:RadNotification>

<div id="decorationZone">
    <telerik:RadSplitter ID="RadSplitter2" runat="server" Width="100%" BorderSize="1" Orientation="Horizontal">
        <telerik:RadPane ID="TopPane" runat="server" Height="125" Scrolling="None" CssClass="radPane">
            <table id="PatientDetailsTable" runat="server" cellspacing="0" cellpadding="0" style="margin-left: 5px; height: 120px;">
                <tr style="vertical-align: top; color: black;">
                    <td style="width: 325px;">
                        <asp:HiddenField ID="PatientIdHiddenField" runat="server" Value="" />
                        <asp:HiddenField ID="PreviousProcIdHiddenField" runat="server" Value="" />
                        <table cellpadding="1" cellspacing="1">
                            <tr>
                                <td style="font-weight: bold;">Name:</td>
                                <td style="max-width: 270px;">
                                    <asp:Label ID="PatientName" runat="server" Text="Not available" Font-Size="Medium" Font-Bold="true" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">
                                    <asp:Label ID="lblCaseNoteNo" runat="server" Text="Hospital no" />:</td>
                                <td>
                                    <asp:Label ID="CNN" runat="server" Text="Not available" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">
                                    <asp:Label ID="lblNHSNo" runat="server" Text="NHS No" />:</td>
                                <td>
                                    <asp:Label ID="NHSNo" runat="server" Text="Not available" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Date of birth:</td>
                                <td>
                                    <asp:Label ID="DOB" runat="server" Text="Not available" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Ethnicity:</td>
                                <td>
                                    <asp:Label ID="Ethnicity" runat="server" Text="Not available" />
                                </td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Record created:</td>
                                <td>
                                    <asp:Label ID="RecCreated" runat="server" Text="Not available" />
                                </td>
                            </tr>
                        </table>
                    </td>
                    <%--Added by rony tfs-4206--%>
                    <td style="width: 175px; border-right: 1px solid #c2d2e2;">
                        <table cellpadding="1" cellspacing="1">
                            <tr>
                                <td style="font-weight: bold;">Address:</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="Address" runat="server" Text="" /></td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Email:</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="Email" runat="server" Text="" /></td>
                            </tr>
                        </table>
                    </td>
                    <td style="width: 240px; border-right: 1px solid #c2d2e2; padding-left: 15px;">
                        <table cellpadding="1" cellspacing="1">
                            <tr>
                                <td style="font-weight: bold;">Telephone no:</td>
                                <td>
                                    <asp:Label ID="TelephoneNo" runat="server" Text="" /></td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Mobile no:</td>
                                <td>
                                    <asp:Label ID="MobileNo" runat="server" Text="" /></td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Next of Kin:</td>
                                <td>
                                    <asp:Label ID="KentOfKin" runat="server" Text="" /></td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold;">Modality:</td>
                                <td>
                                    <asp:Label ID="Modalities" runat="server" Text="" /></td>
                            </tr>
                        </table>
                    </td>
                    <td style="padding-left: 15px; vertical-align: central;">
                        <table cellpadding="1" cellspacing="1">
                            <tr>
                                <td style="font-weight: bold;">GP Detail:</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="GPName" runat="server" Text="" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="PracticeName" runat="server" Text="" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="GPAddress" runat="server" Text="" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <asp:Label ID="lblCNN" runat="server" Text="" Visible="true" />
        </telerik:RadPane>
        <telerik:RadPane ID="radPDBottom" runat="server" Scrolling="Y">
            <telerik:RadSplitter ID="RadSplitter1" runat="server" Width="100%" Height="100%" BorderSize="1" Skin="Windows7" ResizeWithBrowserWindow="true" ResizeMode="AdjacentPane">
                <telerik:RadPane ID="radPaneTreeList" runat="server" MinWidth="200" Width="200" MaxWidth="300"  CssClass="treeListAutoWidthHeight">
                    <div style="margin: 5px 5px;">  <%--   Design section of Tree View of Previous Procedure list   --%>
                       <table>
                           <tr>
                                <td colspan="2">
                                     <asp:RadioButtonList ID="TreeRadioGroupList" runat="server" AutoPostBack="true" Skin="Windows7" RepeatDirection="Horizontal" OnSelectedIndexChanged="TreeviewGroup_SelectedIndexChanged" RepeatColumns="4" BackColor="AliceBlue">
                                               <asp:ListItem Text="Group" Value="1" Enabled="true" />
                                                <asp:ListItem Text="Episode" Value="2" Selected="True" />
                                       </asp:RadioButtonList>
                                </td>
                               <td colspan="2">
                                   <asp:CheckBox ID="SpecialityCheckBox" runat="server" Text="Speciality" AutoPostBack="True" OnCheckedChanged="SpecialityCheckBox_CheckedChanged"  Visible="false" />
                               </td>
                           </tr>
                           </table>
                        <telerik:RadTreeView ID="PrevProcsTreeView" runat="server" Skin="Metro" BackColor="#ffffff" OnClientNodeClicking="onClickingNode"  CssClass="treeViewAutoWidthHeight"
                            OnClientContextMenuShowing="DisableProcedureContextMenu" OnClientContextMenuItemClicking="OnClientContextMenuItemClicking" OnContextMenuItemClick="PrevProcsTreeView_ContextMenuItemClick">
                            <ContextMenus>
                                <telerik:RadTreeViewContextMenu runat="server" ID="PrevProcsTreeViewContextMenu" Skin="Metro">
                                    <Items>
                                        <telerik:RadMenuItem  Text="Edit" Value="Edit" ImageUrl="../Images/icons/edit.png" />
                                        <telerik:RadMenuItem Text="UnLock" Value="UnLock" ImageUrl="../Images/icons/edit.png" />
                                        <telerik:RadMenuItem  Text="Add Procedure" Value="preToProcedure" ImageUrl="../Images/icons/help_faq.png" />
                                        <telerik:RadMenuItem Text="Edit by History" Value="EditByHistory" ImageUrl="../Images/icons/checklist.png" />
                                        <telerik:RadMenuItem  Text="Order to Procedure" Value="OcToProcedure" ImageUrl="../Images/icons/select.png" />
                                        <telerik:RadMenuItem  Text="View OrderComms" Value="ViewOrderComms" ImageUrl="../Images/icons/preview.png" />
                                        <telerik:RadMenuItem  IsSeparator="True" Value="ImagesSeparator" />
                                        <telerik:RadMenuItem  Text="Media" Value="Images" ImageUrl="../Images/icons/camera.png" />
                                        <telerik:RadMenuItem  IsSeparator="True" Value="PrintSeparator" />
                                        <telerik:RadMenuItem  Text="Print Preview" Value="PrintPreview" ImageUrl="../Images/icons/preview.png" />
                                        <telerik:RadMenuItem  Text="Print" Value="Print" ImageUrl="../Images/icons/print.png" />
                                        <telerik:RadMenuItem  IsSeparator="True" Value="PrintSeparator" />
                                        <telerik:RadMenuItem  Text="Post procedural data">
                                            <Items>
                                                <telerik:RadMenuItem Text="Record belated UREASE results" />
                                                <telerik:RadMenuItem Text="Record patient COMFORT LEVELS" Value="comfort-levels" />
                                                <telerik:RadMenuItem Text="Record use of REVERSAL AGENTS" Value="reversal-agents" />
                                                <telerik:RadMenuItem Text="Record PATHOLOGY RESULTS" Value="pathology-results" />
                                                <telerik:RadMenuItem Text="Record POST-PROCEDURE" />
                                            </Items>
                                        </telerik:RadMenuItem>
                                        <telerik:RadMenuItem IsSeparator="True" Value="swho" />
                                        <telerik:RadMenuItem Text="Procedure not carried out" Value="proc-not-carried-out" />
                                        <telerik:RadMenuItem Text="Breath Test" Value="breath-test" />
                                        <telerik:RadMenuItem IsSeparator="True" Value="ImagesSeparator" />
                                        <telerik:RadMenuItem Text="Delete" Value="Delete" ImageUrl="../Images/icons/Cancel.png" />
                                    </Items>
                                </telerik:RadTreeViewContextMenu>
                            </ContextMenus>
                        </telerik:RadTreeView>

                        <%--<div style="text-align: left; border-top: 1px dashed #B8CBDE; padding-top: 10px;">
                                            <telerik:RadButton ID="RadButton1" runat="server" Text="Create Procedure" Icon-PrimaryIconUrl="~/Images/icons/Create.png"
                                                Skin="Office2007" Font-Bold="true" OnClientClicking="validateGMCCodes" />
                                        </div>--%>
                    </div>
                    <div class="pdf-upload-container size-wide" style="position: fixed">
                        <div class="qsf-ib">
                            <%--<p class="infoHeader">
                                                Click the button below to open a RadWindow and see
                                                how easy the access to and from the Content Template is
                                            </p>--%>
                            <div id="ContentTemplateZone" class="qsf-ib">
                                <br />
                                <%--<asp:Button ID="Button5" SkinID="Office2007" Text="Upload PDF" runat="server" OnClientClick="openWinContentTemplate(); return false;" />--%>
                                <telerik:RadButton ID="Button5" Skin="Office2007" Font-Bold="true" Text="Upload PDF" runat="server" OnClientClicking="openWinContentTemplate" AutoPostBack="false" />
                                <br />
                                <%--<asp:Label ID="Label1" Text="" runat="server"></asp:Label>--%>
                            </div>
                        </div>
                        <%--<div class="qsf-ib">
                                              <p class="infoHeader">
                                                  Click the button below to open a RadWindow that loads
                                                  an external page and see how you can use it to navigate in a separate document
                                              </p>
                                              <div id="NavigateUrlZone" class="qsf-ib">
                                                  <br />
                                                  <asp:Button ID="Button6" Text="open the window" runat="server" OnClientClick="openWinNavigateUrl(); return false;" />
                                              </div>
                                          </div>--%>
                    </div>
                    <div id="divContextMenu">
                        <telerik:RadContextMenu ID="RadContextMenu1" runat="server" Skin="Windows7" EnableRoundedCorners="False"
                            EnableShadows="True" Visible="False">
                            <Targets>
                                <telerik:ContextMenuControlTarget ControlID="PrevProcsTreeView" />
                            </Targets>
                            <Items>
                                <telerik:RadMenuItem runat="server" Text="Edit report">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem runat="server" IsSeparator="True">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem runat="server" Text="Print last report">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem runat="server" IsSeparator="True" Value="resultSeparator">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem runat="server" Text="Post procedural data...">
                                    <Items>
                                        <telerik:RadMenuItem runat="server" Text="Enter urease results">
                                        </telerik:RadMenuItem>
                                        <telerik:RadMenuItem runat="server" Text="Record patient comfort levels">
                                        </telerik:RadMenuItem>
                                        <telerik:RadMenuItem runat="server" Text="Record use of reversal agents">
                                        </telerik:RadMenuItem>
                                        <telerik:RadMenuItem runat="server" Text="Record POST-PROCEDURE">
                                        </telerik:RadMenuItem>
                                    </Items>
                                </telerik:RadMenuItem>
                            </Items>
                        </telerik:RadContextMenu>
                    </div>
                </telerik:RadPane>

                <telerik:RadSplitBar ID="RadSplitBar2" runat="server" Orientation="Vertical" Skin="Windows7" />

                <telerik:RadPane ID="radPaneDetails" runat="server" Scrolling="None" Width="995px">
                    <%-- Mahfuz changed to 995px from 975px for alignment--%>

                    <div class="divContainer" style="width: 100%; height: 100%;">
                        <%-- Mahfuz removed  height: 750px; eliminating scrollbars--%>

                        <telerik:RadMultiPage runat="server" ID="RadMultiPage1" Width="100%">
                            <%-- Mahfuz removed   Height="800px" --%>

                            <telerik:RadPageView runat="server" ID="DisplayMessagePageView">
                                <div style="margin-left: 10px; margin-top: 10px;">

                                    <asp:LinkButton ID="lblMessage" runat="server" Text="" Font-Bold="true" Font-Size="Large" Width="95%" OnClick="MessageClicked"></asp:LinkButton>
                                    <%--<asp:Label ID="lblMessage" runat="server" Text="" Font-Bold="true" Font-Size="Large" Width="600" />--%>
                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView runat="server" ID="PreviousProcedurePageView" CssClass="prev-procs-page">

                                <div class="text" style="margin-left: -10px;">
                                    <asp:Label ID="lblProcTitle" runat="server" Text="" Font-Bold="true" />
                                </div>

                                <div style="margin: 2px 5px;">
                                    <table style="border: none; width: 762px;" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td>
                                                <div id="NavButtonsDiv" style="float: left; display: none;">
                                                    <table cellpadding="0" cellspacing="0" style="margin-bottom: 5px;">
                                                        <tr>
                                                            <td>
                                                                <asp:LinkButton ID="GPReportLinkButton" runat="server" CssClass="tab-page-button" OnClientClick="return tabButtonSelected(this)" data-page="gpReport">
                                                                    <img src="../Images/icons/report.gif" alt="Report" />&nbsp;Report
                                                                </asp:LinkButton>

                                                            </td>
                                                            <td>
                                                                <asp:LinkButton ID="ImagesLinkButton" runat="server" CssClass="tab-page-button" OnClientClick="return tabButtonSelected(this)" data-page="images" Visible="false">
                                                                    <img src="../Images/icons/camera.png" alt="Images" />&nbsp;Media
                                                                </asp:LinkButton>
                                                            </td>
                                                            <td>
                                                                <asp:LinkButton ID="PrintLinkButton" runat="server" CssClass="tab-page-button" OnClientClick="return tabButtonSelected(this)" data-page="print">
                                                                    <img src="../Images/icons/print.png" alt="Print" />&nbsp;Print
                                                                </asp:LinkButton>
                                                            </td>
                                                            <td>
                                                                <asp:LinkButton ID="PathologyResultsLinkButton" runat="server" CssClass="tab-page-button" OnClientClick="return tabButtonSelected(this)" data-page="pathResults" Visible="false">
                                                                    <img src="../Images/icons/preview.png" alt="Pathology results" />&nbsp;Pathology Results
                                                                </asp:LinkButton>
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                    </table>
                                                </div>
                                                <div style="float: right; display: none;">
                                                    <asp:LinkButton ID="EditReportLinkButton" runat="server" OnClick="EditReportLinkButton_Click" CssClass="tab-page-button">
                                                        Edit Report&nbsp;<img src="../Images/icons/edit.png" alt="Edit Report" />
                                                    </asp:LinkButton>
                                                </div>

                                                <telerik:RadTabStrip ID="PrevProcSummaryTabStrip" runat="server" Skin="Default" SelectedIndex="0" MultiPageID="RMPPrevProcs"
                                                    OnClientTabSelected="OnClientTabSelected" OnClientTabUnSelected="OnClientTabUnSelected"
                                                    OnClientLoad="TabStripLoad" Style="display: none;">
                                                    <Tabs>
                                                        <telerik:RadTab Text="Report" Selected="true" ImageUrl="../Images/icons/report.gif" />
                                                        <telerik:RadTab Text="Images" Visible="false" ImageUrl="../Images/icons/camera.png" CssClass="Tabs" />
                                                        <telerik:RadTab Text="Print" ImageUrl="../Images/icons/print.png" CssClass="Tabs" />
                                                        <telerik:RadTab Text="Pathology Results" Visible="false" ImageUrl="../Images/icons/preview.png" />
                                                        <telerik:RadTab Text="Other System Procedure" Visible="false" />
                                                        <telerik:RadTab Text="Upload PDF" Visible="false" />
                                                        <telerik:RadTab Text="Delete PDF" Visible="false" />
                                                    </Tabs>
                                                </telerik:RadTabStrip>
                                            </td>
                                            <td style="vertical-align: bottom; text-align: right;">
                                                <telerik:RadTabStrip ID="EditReportTabStrip" runat="server" Skin="Vista" dir="rtl" Style="display: none;">
                                                    <Tabs>
                                                        <telerik:RadTab Text="Edit Report" ImageUrl="../Images/icons/edit.png" CssClass="Tabs" />
                                                    </Tabs>
                                                </telerik:RadTabStrip>
                                            </td>
                                        </tr>
                                    </table>
                                    <telerik:RadMultiPage ID="RMPPrevProcs" runat="server" SelectedIndex="0">
                                        <telerik:RadPageView ID="RPVGPReport" runat="server">
                                            <telerik:RadSplitter ID="Radsplitter3" runat="server" Orientation="Vertical" SplitBarsSize="0px" Width="100%" BorderSize="0" Skin="Windows7">
                                                <telerik:RadPane ID="radPaneReportLeft" runat="server" Scrolling="None">
                                                    <div style="overflow: auto; height: 70vh; width: 850px; border: 1px solid #D0D0D0;" class="ReportBg">
                                                        <div runat="server" id="divReport" clientidmode="Static">
                                                            <table>
                                                                <tr>
                                                                    <td style="width: 65%; vertical-align: top;">
                                                                        <%--<div runat="server" id="alertDiv" style="border: solid; border-color: red; height: auto; text-align: left; width: 450px; display: none">
                                                                        <img id="AlertImage" runat="server" src="~/Images/warning-32x32.png" style="vertical-align: middle; padding-left: 2px; padding-right: 2px" />
                                                                        <label id="NpsaAlertLabel" runat="server" style="word-wrap: break-word"></label>
                                                                    </div>--%>

                                                                        <div class="procText">
                                                                            <asp:Label ID="lblLeftRptText" runat="server" Text="" />
                                                                        </div>
                                                                    </td>
                                                                    <td style="vertical-align: top;">
                                                                        <div align="right" style="width: 260px">
                                                                            <asp:Label ID="lblRightRptText" runat="server" Text="" /><br />
                                                                            <asp:Label ID="lblBowelPrep" runat="server" Visible="false"></asp:Label><br />
                                                                        </div>
                                                                        <div style="margin-top: 15px; border: 1px solid #C8C8C8">
                                                                            <div id="DiagramDiv" class="DivDiagramReport" runat="server" clientidmode="Static" />
                                                                        </div>
                                                                        <div style="margin-top: 5px; width: 260px">
                                                                            <asp:Label ID="lblAfterDiagram" runat="server" Text="" />
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </telerik:RadPane>
                                            </telerik:RadSplitter>
                                        </telerik:RadPageView>

                                        <telerik:RadPageView ID="RPVImages" runat="server">
                                            <%--   design section of Procedure Summary onClick   --%>
                                            <div style="overflow: auto; height: calc(75vh - 25px); width: 850px; border: 1px solid #D0D0D0;" class="ReportBg">
                                                <div style="margin: 20px 15px;" class="text2" id="NoRowsDiv" runat="server" visible="false">
                                                    No photos/videos attached
                                                </div>

                                                <asp:ObjectDataSource ID="PhotosObjectDataSource" runat="server" SelectMethod="GetPrintReportPhotos" TypeName="UnisoftERS.DataAccess">
                                                    <SelectParameters>
                                                        <asp:Parameter Name="operatingHospitalId" DbType="Int32" />
                                                        <asp:Parameter Name="procedureId" DbType="Int32" />
                                                        <asp:Parameter Name="episodeNo" DbType="Int32" />
                                                        <asp:Parameter Name="patientComboId" DbType="String" />
                                                        <asp:Parameter Name="ColonType" DbType="Int32" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>

                                                <asp:DataList ID="GPPhotosListView" runat="server" DataSourceID="PhotosObjectDataSource" RepeatColumns="2" RepeatDirection="Horizontal">
                                                    <ItemTemplate>
                                                        <asp:HyperLink runat="server" NavigateUrl='<%# Eval("PhotoUrl") %>' Target="_popupWin" ImageUrl='<%# Eval("PhotoUrl") %>' ImageWidth="300" ImageHeight="222" Text='<%#Eval("PhotoTitle") %>' />
                                                        <div><%# Eval("PhotoTitle") %></div>
                                                        <br />
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </div>
                                        </telerik:RadPageView>

                                        <telerik:RadPageView ID="RPVPrintOptions" runat="server">
                                            <div id="divPrintInitiate" style="overflow: hidden; height: 470px; width: 760px; border: 1px solid #D0D0D0;" class="ReportBg">

                                                <unisoft:PrintInitiate runat="server" ID="PrintInitiateUserControl" />

                                            </div>

                                        </telerik:RadPageView>

                                        <telerik:RadPageView ID="RPVPathologyResuts" runat="server">
                                            <div id="divPathologyResults" style="overflow-y: auto; overflow-x: hidden; height: 470px; width: 760px; border: 1px solid #D0D0D0;" class="ReportBg">
                                                <unisoft:PathologyResults runat="server" ID="PathologyResultsUserControl" />
                                            </div>

                                        </telerik:RadPageView>

                                        <telerik:RadPageView ID="RPVPDFView" runat="server" Style="height: 470px !important; width: 760px;">
                                        </telerik:RadPageView>

                                        <%--<telerik:RadPageView ID="RadPageView1" runat="server">
                                            <div id="divPrintGallery" style="overflow: hidden; height: 470px; width: 760px; border: 1px solid #D0D0D0;" class="ReportBg">
                                                <telerik:RadImageGallery ID="RadImageGallery1" runat="server" DataImageField="PhotoUrl" DataDescriptionField="PhotoTitle" Width="500">
                                                    <ThumbnailsAreaSettings ThumbnailWidth="95px" ThumbnailHeight="90px" Height="90px" />
                                                    <ImageAreaSettings Height="389px" ResizeMode="Fit" />
                                                </telerik:RadImageGallery>
                                            </div>
                                        </telerik:RadPageView>--%>
                                    </telerik:RadMultiPage>
                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView runat="server" ID="NewPreassessmentProcedurePageView" Selected="false" Scrolling="y">
                                <div style="margin: -4px -7px;width:100%;overflow-y: auto" class="new_preassessment"> <%--   design section of New Procedure   --%>
                                    <div class="text">
                                        <table style="width: 100%;">
                                            <tr>
                                                <td style="width: 30%" id="PreAssessmentTitle" runat="server"><b>New Pre Assessment</b>&nbsp;&nbsp;<asp:Label ID="Label4" runat="server" Text="" ForeColor="Blue"></asp:Label></td>
                                                <td style="font-size: small; text-align: right; width: 70%">
                                                    <img src="../Images/NEDJAG/Mand.png" />Mandatory&nbsp;&nbsp;</td>
                                              </tr>
                                        </table>
                                        </div>
                                       <div id="frameNewProc1" style="margin: -5px 18px;">
                                        <table border="0" class="lblText" id="table1" runat="server" cellspacing="3" cellpadding="0" style="width: 100%;">
                                           <tr>
                                               <td><asp:HiddenField ID="PreAssessmentHiddenField" runat="server" /></td>
                                               <td><asp:HiddenField ID="IsNewPreAssess" runat="server" /></td>

                                           </tr>

                                            <tr>
                                               
                                                <td style="width: 50%;margin-left:10px">
                                                    <span>Start time</span>
          
                                                    <telerik:RadDateInput style="margin-left: 53px;width: 100px !important"  ID="ProcedureStartDateRadTimeInput" runat="server"  DisplayDateFormat="dd/MM/yyyy" OnClientDateChanged="onPreAssessDateChanged" CssClass="procedure-start-date" />
                                                    <telerik:RadTimePicker style="margin-left: 10px;width: 75px" TimeFormat="HH" ID="ProcedureStartRadTimePicker" AutoPostBack="true" runat="server" Enabled="true"  OnSelectedDateChanged="PreAssessmentRadTimePicker_SelectedDateChanged"  CssClass="procedure-start-time">
                                                    </telerik:RadTimePicker>
                                                    <telerik:RadButton ID="btnStartDateTimeNow" runat="server" OnClick="PreAssessTimeNow_Click" Text="Now"  AutoPostBack="true"   />
                                                </td>
                                            </tr>
                                            <tr>
                 
                                            <td style="width: 100%;">
                                                <span style="display: inline-block; vertical-align: middle;">Procedure</span>
                                                <telerik:RadComboBox 
                                                    ID="PreAssessmentProcedureTypeRadComboBox" 
                                                    runat="server" 
                                                    CheckBoxes="true" 
                                                    OnSelectedIndexChanged="PreAssessmentProcedureTypeRadComboBox_SelectedIndexChanged" 
                                                    AutoPostBack="true" 
                                                    EnableCheckAllItemsCheckBox="true"  
                                                    Skin="Windows7" 
                                                    style="display: inline-block !important; margin-left: 50px;margin-top: 5px" />
                                            </td>
                                            </tr>
                                        </table>
                                        <div runat="server" id="comorbidity">
                                            <PreProc:CoMorbidity ID="PreProcCoMorbidity" runat="server" />
                                        </div> 
                                           <div style="padding-bottom: 7px; margin-top: 28px">
                                        <asp:Repeater ID="PreAssessmentSectionsRepeater" runat="server" OnItemDataBound="PreAssessmentQuestionsRepeater_ItemDataBound">
                                            <HeaderTemplate>
                                                <table class="DataBoundTable" cellpadding="3" cellspacing="3" style="width: 100%">
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <tr>
                                                    <td colspan="2">
                                                        <div class="control-section-header abnorHeader" id="sectionHeader" runat="server"><%# Eval("SectionName") %>&nbsp; </div>
                                                    </td>
                                                </tr>
                                                <asp:Repeater ID="PreAssessmentQuestionsRepeater" runat="server" OnItemDataBound="PreAssessmentQuestionRepeater_ItemDataBound">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td style="vertical-align: top; width: 45%;">
                                                                <asp:HiddenField ID="QuestionIdHiddenField" runat="server" Value='<%#Eval("QuestionId") %>'/>
                                                                       <div style="margin-left: 10px; display: inline-block;">
                                                                                <asp:Image ID="PreQuestionMandatoryImage" runat="server" ImageUrl="../Images/NEDJAG/Mand.png" AlternateText="Mandatory Field" />
                                                                                <telerik:RadLabel runat="server" ID="lblQuestion" Text='<%#Eval("Question") %>' />
                                                                         </div>
                                                            </td>
                                                            <td style="vertical-align: top; width: 55%;">
                                                                <asp:HiddenField ID="AnswerIdHiddenField" runat="server" Value='<%#Eval("AnswerId") %>'/>
                                                                 <telerik:RadComboBox ID="DropdownOptionsRadComboBox" runat="server" Skin="Metro" CssClass="assessment-dropdown-combobox" OnClientSelectedIndexChanged="onComboBoxSelectionChange" data-itemid='<%#Eval("QuestionId") %>' data-answerid='<%# Eval("AnswerId") %>'></telerik:RadComboBox>
                                                                
                                                                <asp:RadioButtonList ID="QuestionOptionRadioButton" runat="server" AutoPostBack="false" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="assessment-question-option" data-itemid='<%#Eval("QuestionId") %>' data-answerid='<%# Eval("AnswerId") %>' Style="margin-right: 10px;">
                                                                    <asp:ListItem Text="Yes" Value="1" style="margin-right: 10px;" />
                                                                    <asp:ListItem Text="No" Value="0" style="margin-right: 10px;" />
                                                                </asp:RadioButtonList>
                                                                <telerik:RadTextBox ID="QuestionAnswerTextBox" runat="server" Skin="Metro" CssClass="assessment-question-input" data-itemid='<%#Eval("QuestionId") %>' data-answerid='<%# Eval("AnswerId") %>' />
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ItemTemplate>
                                            <FooterTemplate>
                                                </table>
                                            </FooterTemplate>
                                        </asp:Repeater>
                                        </div>
                                        </div>
                                         <table>
                                               <tr>
                                               <td colspan="12">
                                                   <div class="preAssessBtn" id="preAssessBtnDiv" runat="server">
            
                                                       <telerik:RadButton ID="CreatePreAssessmentProcedureButton" runat="server" Text="Save Pre Assessment" CssClass="RadButton RadButton_Metro rbButton rbRounded rbPrimaryButton"
                                                           Skin="Metro" Font-Bold="true" Height="20px" OnClientClicking="validateQuestions" AutoPostBack="false"/>
                                                       <div style="display: none">
                                                           <telerik:RadButton ID="CreatePreAssessmentProcedureButton1" runat="server" Text="Create Procedure" OnClick="CreatePreAssessmentProcedureButton1_Click"
                                                               Skin="Metro" Font-Bold="true" Height="20px"  AutoPostBack="true"/>
                                                     </div>
                                                </div>
                                               </td>
                                           </tr>
                                       </table>
                           
                                </div>
                            </telerik:RadPageView>


                            <telerik:RadPageView runat="server" ID="NewProcedurePageView" Selected="false" Scrolling="y">
                                <div style="margin: -4px -7px;width:100%;overflow-y: auto" class="new_preassessment"> <%--   design section of New Procedure   --%>
                                    <div class="text">
                                        <table style="width: 100%;">
                                            <tr>
                                                <td style="width: 30%"><b>New Procedure</b>&nbsp;&nbsp;<asp:Label ID="lblOCProcedure" runat="server" Text="" ForeColor="Blue"></asp:Label></td>
                                                <td style="font-size: small; text-align: right; width: 70%">
                                                    <img src="../Images/NEDJAG/Mand.png" />Mandatory&nbsp;&nbsp;<img src="../Images/NEDJAG/NED.png" />National Data Set Requirement&nbsp;&nbsp;<img src="../Images/NEDJAG/JAG.png" />JAG Requirement</td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div id="frameNewProc" style="margin: -5px 18px;">
                                        <table border="0" class="lblText" id="tableNewProc" runat="server" cellspacing="3" cellpadding="0" style="width: 890px;">
                                            <tr>
                                                <td style="width: 80px;">
                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;Speciality:</td>
                                                <td colspan="2">
                                                    <asp:RadioButtonList ID="ProductRadioButtonList" runat="server" AutoPostBack="true" Skin="Windows7" OnSelectedIndexChanged="ProductRadioButtonList_SelectedIndexChanged" RepeatDirection="Horizontal" RepeatColumns="4" onclick="highlightListControl(this);" BackColor="AliceBlue">
                                                        <asp:ListItem Text="Gastrointestinal" Value="1" Selected="True" />
                                                        <asp:ListItem Text="Thoracic" Value="2" Enabled="true" />
                                                        <asp:ListItem Text="Urology" Value="3" Enabled="true" />
                                                    </asp:RadioButtonList>
                                                    <%--<telerik:RadComboBox ID="ProductComboBox1" runat="server" AutoPostBack="true" Skin="Windows7" Width="130" />--%>
                                                </td>
                                                <td>Date:</td>
                                                <td>
                                                    <telerik:RadDatePicker ID="ProcedureDate" runat="server" Width="100px" Skin="Windows7" />
                                                </td>
                                                <td>Time:
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox OnClientSelectedIndexChanged="OnClientSelectedIndexChanged" ID="TimeComboBox" Width="50" runat="server">
                                                        <Items>
                                                            <telerik:RadComboBoxItem Value="AM" Text="AM" />
                                                            <telerik:RadComboBoxItem Value="PM" Text="PM" />
                                                        </Items>
                                                    </telerik:RadComboBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="border_bottom" colspan="5"></td>
                                            </tr>
                                            <tr>
                                                <td style="text-align: left; width: 80px;">
                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;Procedure: 
                                                </td>
                                                <td style="width: 150px!important; padding-right: 5px;"><%-- Mahfuz used dirty fixing width:150px!imp--%>
                                                    <div class="left" style="background-color: aliceblue;">
                                                        <telerik:RadComboBox ID="ProcTypeRadComboBox" runat="server" OnClientSelectedIndexChanged="ProcTypeRadComboBoxChanged" />
                                                    </div>
                                                </td>
                                                <td id="ProcedurePointsTD" class="ProcedurePointsTDCSS" runat="server" style="width: 95px;">Points:
                                                                    <telerik:RadNumericTextBox ID="ProcedurePointsRadNumericTextBox" runat="server"
                                                                        ShowSpinButtons="false"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="0.5"
                                                                        Width="50px"
                                                                        MinValue="1" MaxValue="24" Skin="Metro" RenderMode="Lightweight">
                                                                        <NumberFormat DecimalDigits="1" />
                                                                    </telerik:RadNumericTextBox></td>
                                                <td style="text-align: center; border-left: 1pt dashed #B8CBDE;">
                                                    <div style="font-weight: normal; padding: 2px;">
                                                        <!--<asp:Label ID="ImagePortNameLabel" runat="server" Text="None" />
                                                                    <asp:HiddenField ID="ImagePortIdHiddenField" runat="server" />-->
                                                        &nbsp;&nbsp;&nbsp;ImagePort:
                                                    </div>
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="ImagePortComboBox" runat="server" Skin="Metro" Width="120px" OnClientSelectedIndexChanged="openChangeImageportMessage" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" class="border_bottom"></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <img src="../Images/NEDJAG/NED.png" alt="NED Field" />&nbsp;Category:</td>
                                                <td colspan="3">
                                                    <div class="left">
                                                        <%--'Added by rony tfs-3489--%>
                                                        <telerik:RadComboBox ID="CategoryRadComboBox" runat="server" Skin="Windows7" AutoPostBack="false" OnClientSelectedIndexChanged="setCategoryOptions" OnClientLoad="OnCategoryOptionsLoad" Width="256"/>
                                                        <%--... this belongs to the CategoryRadComboBox ->
                                                            <asp:RadioButtonList ID="CategoryRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Horizontal" onclick="highlightListControl(this);" />--%>
                                                        <%--<telerik:RadComboBox ID="CategoryComboBox" runat="server" Skin="Windows7" Width="130" />--%>
                                                    </div>
                                                    <%--<div class="left"> <asp:RequiredFieldValidator ID="CategoryRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                                        ControlToValidate="CategoryRadioButtonList" EnableClientScript="true" Display="Dynamic"
                                                                        ErrorMessage="Category is required" Text="*" ToolTip="This is a required field"
                                                                        ValidationGroup="CreateProc">
                                                                    </asp:RequiredFieldValidator></div>--%>
                                                    <div id="divCategory_Emergency" style="padding-left: 20px; float: left; height: 22px; display: none;">
                                                        <asp:RadioButtonList ID="rblEmergencyNedCatOption" runat="server" Skin="Windows7" RepeatColumns="2" RepeatDirection="Horizontal" onclick="highlightListControl(this);">
                                                            <asp:ListItem Value="1" Selected="True">in</asp:ListItem>
                                                            <asp:ListItem Value="2">out of hours</asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </div>
                                                    <div id="divCategory_OpenAccess" style="padding-left: 20px; float: left; height: 22px; display: none;">
                                                        <asp:RadioButtonList ID="rblOpenAccessCatOption" runat="server" Skin="Windows7" RepeatColumns="2" RepeatDirection="Horizontal" onclick="highlightListControl(this);">
                                                            <asp:ListItem Value="1" Selected="True">OGD</asp:ListItem>
                                                            <asp:ListItem Value="2">col/sig</asp:ListItem>
                                                        </asp:RadioButtonList>
                                                    </div>
                                                    <div id="divCategory_Elective" style="padding-left: 20px; float: left; display: none;">
                                                        <asp:CheckBox ID="chkElectiveNED" runat="server" Text="On waiting list" TextAlign="Right" Checked="true" />
                                                    </div>
                                                </td>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <img src="../Images/NEDJAG/Ned.png" alt="Mandatory Field" />&nbsp;Service provider:</td>
                                                <td class="">
                                                    <telerik:RadComboBox ID="ServiceProviderRadComboBox" runat="server" AutoPostBack="false" OnClientSelectedIndexChanged="ProviderTypeComboBoxChanged" />
                                                </td>
                                                <td class="other-provider-input" style="display: none;" colspan="2">
                                                    <img src="../Images/NEDJAG/Ned.png" alt="Mandatory Field" />&nbsp;Other:&nbsp;
                                                                <telerik:RadTextBox ID="OtherProviderRadTextBox" runat="server" Skin="Metro" RenderMode="Lightweight" />
                                                </td>
                                                <td class="other-type-input" style="display: none;"></td>
                                            </tr>
                                            <tr>

                                                <td>
                                                    <img src="../Images/NEDJAG/Ned.png" alt="Mandatory Field" />&nbsp;Referral Type:</td>
                                                <td class="">
                                                    <telerik:RadComboBox ID="ReferrerTypeComboBox" runat="server" AutoPostBack="false" OnClientSelectedIndexChanged="ReferrerTypeComboBoxChanged" />


                                                </td>
                                                <td class="gp-referral-text-input" style="display: none;" colspan="3">
                                                    <%--<img src="../Images/NEDJAG/Ned.png" alt="Mandatory Field" />&nbsp;GP Referral:&nbsp;--%>
                                                                &nbsp;Referral:&nbsp;
                                                                <telerik:RadTextBox ID="GPReferralTextBox" runat="server" Skin="Metro" />
                                                </td>
                                                <td class="other-type-input" style="display: none;" colspan="2">
                                                    <img src="../Images/NEDJAG/Ned.png" alt="Mandatory Field" />&nbsp;Other:&nbsp;
                                                                <telerik:RadTextBox ID="OtherReferrerTypeTextBox" runat="server" Skin="Metro" />
                                                </td>
                                                <td class="other-type-input" style="display: none;"></td>

                                            </tr>
                                            <tr class="referral-consultant-row" style="display: none;">
                                                <td colspan="2">
                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;Referring Consultant:
                                                </td>
                                                <td style="padding-left: 2px;">
                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;Speciality:
                                                </td>
                                                <td style="padding-left: 2px;" colspan="2">
                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;Referring Hospital:
                                                </td>
                                            </tr>
                                            <tr class="referral-consultant-row" style="display: none;">
                                                <td colspan="2" id="referringConsultantTd">
                                                    <div class="left" style="float: right;">
                                                        <telerik:RadMultiColumnComboBox runat="server" ID="ConsultantComboBox" Skin="Metro" SelectionBoxesVisibility="Hidden" AutoPostBack="false"
                                                            Height="300px" DropDownWidth="600px" Width="100%"
                                                            Filter="contains" FilterFields="FullName, GroupName, Hospital"
                                                            DataTextField="FullName" DataValueField="ConsultantID">
                                                            <ColumnsCollection>
                                                                <telerik:MultiColumnComboBoxColumn Field="FullName" Title="Referring Consultant" />
                                                                <telerik:MultiColumnComboBoxColumn Field="GroupName" Title="Speciality" />
                                                                <telerik:MultiColumnComboBoxColumn Field="Hospital" Title="Referring Hospital" />
                                                            </ColumnsCollection>
                                                            <ClientEvents OnSelect="ConsultantChanged" />
                                                        </telerik:RadMultiColumnComboBox>
                                                    </div>
                                                </td>
                                                <td style="padding-left: 2px;">
                                                    <div class="left">
                                                        <telerik:RadComboBox ID="SpecialityRadComboBox" runat="server" Skin="Windows7" Width="200px" AutoPostBack="false" Enabled="True" ShowToggleImage="True" />
                                                    </div>
                                                </td>
                                                <td style="padding-left: 2px;" colspan="2">
                                                    <div class="left">
                                                        &nbsp;&nbsp;&nbsp;<telerik:RadComboBox ID="HospitalComboBox" runat="server" Skin="Windows7" Width="200px" OnSelectedIndexChanged="HospitalChanged" AutoPostBack="false" />
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <img src="../Images/NEDJAG/NED.png" alt="NED Field" />&nbsp;Patient Status:
                                                </td>
                                                <td>
                                                    <asp:RadioButtonList ID="PatStatusRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="4" onclick="javascript:PatStatusClicked();highlightListControl(this);" />
                                                </td>
                                                <td align="left" id="PatientWardCell1" runat="server" style="display: none;">
                                                    <span>Ward:</span>
                                                    <div id="PatientWardCell2" runat="server" style="display: inline-block; margin-left: 5px; vertical-align: middle;">
                                                        <telerik:RadComboBox ID="WardComboBox" runat="server" Skin="Windows7" Width="120" Filter="StartsWith" />
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <img src="../Images/NEDJAG/NED.png" alt="NED Field" />&nbsp;Patient Type:</td>
                                                <td colspan="3">
                                                    <div class="left">
                                                        <asp:RadioButtonList ID="PatientTypeRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="4" onclick="highlightListControl(this);" />
                                                    </div>
                                                </td>
                                                <td></td>
                                            </tr>                                            
                                            <tr>
                                                <td colspan="3" style="padding-bottom: 20px;">
                                                    <div class="subText border_bottom" style="height: 10px; text-align: left; padding: 6px 0px;">
                                                        <span style="background-color: white; padding-right: 6px;">
                                                            <asp:Label ID="ConsultantEndoscopistsLabel" runat="server" Text="Consultant/Endoscopists" />
                                                        </span>
                                                    </div>
                                                </td>
                                                <td colspan="2" style="text-align: center;">
                                                    <div style="text-align: center; width: 100%; background-color: aliceblue; border: 1px dashed #dae1e7;">
                                                        <asp:CheckBox ID="SetDefaultCheckBox" runat="server" Text="Set as default staff for this list" TextAlign="Left" />
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 120px; white-space: nowrap;">
                                                    <img src="../Images/NEDJAG/NED.png" alt="NED Field" />&nbsp;<asp:Label ID="ListTypeLabel" runat="server" Text="List Type:" /></td>
                                                <td>
                                                    <telerik:RadComboBox ID="ListTypeComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="setEndoscopistRole" />
                                                </td>
                                                <td></td>
                                                <td style="width: 120px; white-space: nowrap;">
                                                    <img src="../Images/NEDJAG/NED.png" alt="NED Field" />&nbsp;<asp:Label ID="Nurse1Label" runat="server" Text="Nurse 1:" /></td>
                                                <td>
                                                    <telerik:RadComboBox ID="Nurse1ComboBox" runat="server" OnClientSelectedIndexChanged="nurse1Validation" Width="130" Skin="Windows7" MarkFirstMatch="true" Filter="Contains" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 120px; white-space: nowrap;"> <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;<asp:Label ID="ListConsultantLabel" runat="server" Text="List Consultant:" /></td> <%-- 4107 --%>
                                                <td>
                                                    <telerik:RadComboBox ID="ListConsultantComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="ListConsultantChanged" MarkFirstMatch="true" Filter="Contains" />
                                                    <asp:HiddenField ID="ListConsultantGMCHiddenField" runat="server" />
                                                </td>
                                                <td></td>
                                                <td>
                                                    <img src="../Images/NEDJAG/NED.png" alt="NED Field" />&nbsp;<asp:Label ID="Nurse2Label" runat="server" Text="Nurse 2:" /></td>
                                                <td>
                                                    <telerik:RadComboBox ID="Nurse2ComboBox" runat="server" OnClientSelectedIndexChanged="nurse2Validation" Width="130" Skin="Windows7" MarkFirstMatch="true" Filter="Contains" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <img src="../Images/NEDJAG/JAGNED.png" alt="NED/JAG Field" />&nbsp;<asp:Label ID="Endoscopist1Label" runat="server" Text="Endoscopist 1:" MarkFirstMatch="true" Filter="Contains" /></td>
                                                <td>
                                                    <div class="left">
                                                        <telerik:RadComboBox ID="Endo1ComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="Endo1Changed" MarkFirstMatch="true" Filter="Contains" />



                                                    </div>
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="Endo1RoleComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="changeEndoRole"></telerik:RadComboBox>
                                                    <asp:HiddenField ID="Endo1GMCHiddenField" runat="server" />
                                                </td>
                                                <td>&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="Nurse3Label" runat="server" Text="Assistant/Nurse 3:" /></td>
                                                <td>
                                                    <telerik:RadComboBox ID="Nurse3ComboBox" runat="server" Width="130" OnClientSelectedIndexChanged="nurse3Validation" Skin="Windows7" MarkFirstMatch="true" Filter="Contains" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="Endoscopist2Label" runat="server" Text="Endoscopist 2:" MarkFirstMatch="true" Filter="Contains" /></td>
                                                <td>
                                                    <telerik:RadComboBox ID="Endo2ComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="Endo2Changed" MarkFirstMatch="true" Filter="Contains" />


                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="Endo2RoleComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="changeEndoRole" />
                                                    <asp:HiddenField ID="Endo2GMCHiddenField" runat="server" />
                                                </td>
                                                <td>&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="Nurse4Label" runat="server" Text="Trainee:" /></td>
                                                <td>
                                                    <telerik:RadComboBox ID="Nurse4ComboBox" runat="server" OnClientSelectedIndexChanged="nurse4Validation" Width="130" Skin="Windows7" MarkFirstMatch="true" Filter="Contains" />
                                                </td>
                                            </tr>
                                            <%-- <tr>
                                            <td colspan="4" class="border_bottom">
                                                <table style="width: 100%; margin-top: 10px; margin-left: -3px;">
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="SetDefaultCheckBox" runat="server" Text="Set as default staff for this list" />
                                                        </td>
                                                        <td style="text-align: right;">
                                                            <asp:Label ID="PatientConsentLabel" Text="Has the patient given consent?" runat="server" Style="font-weight: 500;"></asp:Label>
                                                        </td>
                                                        <td style="text-align: right; width: 85px;">
                                                            <asp:RadioButtonList ID="ConsentRadioButtonList" runat="server" Style="display: inline" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2" onclick="highlightListControl(this);">
                                                                <asp:ListItem Text="No" Value="1" />
                                                                <asp:ListItem Text="Yes" Value="2" />
                                                            </asp:RadioButtonList>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>--%>
                                            <%--<tr>
                                                <td runat="server" id="tdSeperatorPatientConsent" colspan="2" style="padding-bottom: 15px;">
                                                    <div class="subText border_bottom" style="height: 10px; text-align: left; padding: 6px 0px;" />
                                                </td>
                                                <td colspan="2" style="text-align: center;">
                                                    <div style="text-align: center; width: 100%; background-color: aliceblue; border: 1px dashed #dae1e7;">
                                                        <asp:CheckBox ID="SetDefaultCheckBox" runat="server" Text="Set as default staff for this list" TextAlign="Left" />
                                                    </div>
                                                </td>
                                            </tr>--%>
                                            <tr>
                                                <td colspan="5">&nbsp;</td>
                                            </tr>
                                            <tr runat="server" id="tr1">
                                                <td colspan="5">
                                                    <table border="0" style="width: 100%;">
                                                        <tr>
                                                            <td style="width: 284px;">
                                                                <div class="left" style="padding-top: 4px;">
                                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;<asp:Label ID="Label1" Text="Pre-procedure checklist complete?" runat="server" Style="font-weight: 500; vertical-align: auto; padding-bottom: 10px;"></asp:Label>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div class="left">
                                                                    <asp:RadioButtonList ID="ChecklistCompleteRadioButtonList" onclick="highlightListControl(this);" runat="server" Style="display: inline;" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2">
                                                                        <asp:ListItem Text="No" Value="0" />
                                                                        <asp:ListItem Text="Yes" Value="1" />
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>

                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>

                                                <td colspan="5">
                                                    <table border="0" runat="server" id="trPatientConsent" style="width: 100%;">
                                                        <tr>
                                                            <td style="width: 284px;">
                                                                <div class="left" style="padding-top: 4px;">
                                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;<asp:Label ID="PatientConsentLabel" Text="Has the patient given consent?" runat="server" Style="font-weight: 500; vertical-align: auto; padding-bottom: 10px;"></asp:Label>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div class="left">
                                                                    <asp:RadioButtonList ID="ConsentRadioButtonList" runat="server" onclick="patientConcentcombox(this)" Style="display: inline;" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2">
                                                                        <asp:ListItem Text="No" Value="1" />
                                                                        <asp:ListItem Text="Yes" Value="2" />
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                                
                                                            </td>
                                                            <td >
                                                                <div id="PatientConsentId" runat="server" style="display: none;">
                                                                    <telerik:RadComboBox ID="PatientConsentRadComboBox" runat="server" Skin="Metro" Width="120px" />
                                                                    <telerik:RadTextBox ID="PatientConsentOtherTextBox" runat="server" Skin="Metro"  Width="120px"></telerik:RadTextBox>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5">
                                                    <table runat="server" id="tdPatientsNotesAvailable" style="width: 100%;">
                                                        <tr>
                                                            <td style="width: 284px;">
                                                                <div class="left" style="padding-top: 4px;">
                                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;<asp:Label ID="Label2" Text="Patient notes available" runat="server" Style="font-weight: 500; vertical-align: auto; padding-bottom: 10px;"></asp:Label>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div class="left">
                                                                    <asp:RadioButtonList ID="PatientNotesRadioButtonList" runat="server" onclick="bindJQEvents(this);" Style="display: inline;" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2">
                                                                        <asp:ListItem Text="No" Value="0" />
                                                                        <asp:ListItem Text="Yes" Value="1" />
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                            <td id="ReferralLetterTD" runat="server" style="display: none;">&nbsp;
                                                                <asp:CheckBox ID="ReferralLetterCheckBox" runat="server"
                                                                    Text="But referral letter/documentation WAS available" />
                                                            </td>
                                                            <%--<td style="width: 180px;">
                                                                <asp:CheckBox ID="NoNotesCheckBox" runat="server" Text="Patient notes NOT available"
                                                                    onchange="ToggleReferral();" /></td>
                                                            --%>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr class="ImageGenderTR" style="display: none">

                                                <td colspan="5">
                                                    <table border="0" style="width: 100%">
                                                        <tr>
                                                            <td style="width: 284px;">
                                                                <div class="left" style="padding-top: 4px;">
                                                                    <img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" />&nbsp;<asp:Label ID="Label3" Text="Choose Image Type?" runat="server" Style="font-weight: 500; vertical-align: auto; padding-bottom: 10px;"></asp:Label>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div class="left">
                                                                    <asp:RadioButtonList ID="ImageGenderID" runat="server" onclick="highlightListControl(this);" Style="display: inline;" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2">
                                                                        <asp:ListItem Text="Male" Value="2" />
                                                                        <asp:ListItem Text="Female" Value="3" />
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>

                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5">
                                                    <div style="text-align: left; border-top: 1px dashed #B8CBDE; padding-top: 10px;">
                                                        <%--<telerik:RadButton ID="CreateProcedureButton" runat="server" Text="Create Procedure" Icon-PrimaryIconUrl="~/Images/icons/Create.png"
                                                    Skin="Office2007" Font-Bold="true" OnClientClicking="validateGMCCodes" />--%>
                                                        <telerik:RadButton ID="CreateProcedureButton" runat="server" Text="Create Procedure" CssClass="RadButton RadButton_Metro rbButton rbRounded rbPrimaryButton"
                                                            Skin="Metro" Font-Bold="true" OnClientClicking="validateGMCCodes" Height="20px" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>


                                        <telerik:RadWindowManager ID="AddNewWardRadWindowManager" runat="server" ShowContentDuringLoad="false" VisibleStatusbar="false"
                                            Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                                            <Windows>
                                                <telerik:RadWindow ID="GMCCodeRadWindow" runat="server" Title="GMC Code required"
                                                    Width="550px" MinHeight="250px" ReloadOnShow="true" ShowContentDuringLoad="false"
                                                    Modal="true" VisibleStatusbar="false" Skin="Metro" Behaviors="Close">
                                                </telerik:RadWindow>
                                                <telerik:RadWindow ID="PrintWindow1" runat="server" Title="Print report"
                                                    Width="800px" Height="900px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="true"
                                                    Modal="true" VisibleStatusbar="false" Skin="Office2010Blue" Behaviors="Close">
                                                </telerik:RadWindow>
                                                <telerik:RadWindow ID="AddNewConsultantRadWindow" runat="server" Title="Add consultant"
                                                    Width="525px" Height="700px" ReloadOnShow="true" ShowContentDuringLoad="true"
                                                    Modal="true" VisibleStatusbar="false" Skin="Office2010Blue" Behaviors="Close">
                                                </telerik:RadWindow>
                                                <telerik:RadWindow ID="ChangeImageportMessage" runat="server" Title="Correct ImagePort?"
                                                    Width="500px" Height="160px" ReloadOnShow="true" ShowContentDuringLoad="true"
                                                    Modal="true" VisibleStatusbar="false" Skin="Metro">
                                                    <ContentTemplate>
                                                        <div id="ImagePortSelectedMessage" style="text-align: center;">
                                                        </div>
                                                        <telerik:RadButton ID="ImagePortOk" runat="server" Text="Yes" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeChangeImageportMessage"/>
                                                        <telerik:RadButton ID="ImagePortCancel" runat="server" Text="No" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeClearChangeImageportMessage"/>
                                                    </ContentTemplate>
                                                </telerik:RadWindow>
                                                <telerik:RadWindow ID="AddNewWardRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Ward"
                                                    KeepInScreenBounds="true" Width="400px" Height="150px">
                                                    <ContentTemplate>
                                                        <table cellspacing="3" cellpadding="3" style="width: 100%; text-align: center;">

                                                            <tr>
                                                                <td>
                                                                    <br />
                                                                    <div class="left">
                                                                        New ward :
                                                                    <telerik:RadTextBox ID="AddNewWardRadTextBox" runat="Server" Width="250px" />
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px; text-align: center;">
                                                                        <telerik:RadButton ID="AddNewWardSaveRadButton" runat="server" Text="Save" Skin="WebBlue" OnClientClicking="checkValidWard" />
                                                                        &nbsp;&nbsp;
                                                                        <telerik:RadButton ID="AddNewWardCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeAddWardWindow" />
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <div>
                                                            <telerik:RadToolTip runat="server" ID="AddNewWardErrorRadToolTip"
                                                                Position="MiddleRight" Skin="Web20" Style="background-color: red;"
                                                                HideEvent="ManualClose" RelativeTo="BrowserWindow">
                                                                <div id="AddNewWardToolTipDiv" class="aspxValidationSummary"></div>
                                                            </telerik:RadToolTip>
                                                        </div>
                                                    </ContentTemplate>
                                                </telerik:RadWindow>
                                                <telerik:RadWindow ID="SurgicalChecklistRadWindow" Modal="true" runat="server" Title="WHO surgical safety checklist"
                                                    KeepInScreenBounds="true" Width="450px" Height="120px" VisibleStatusbar="false" ShowContentDuringLoad="false" SkinID="Metro">
                                                    <ContentTemplate>
                                                        <table style="text-align: center;">
                                                            <tr>
                                                                <td>
                                                                    <label>Has the WHO surgical safety checklist completed?</label>
                                                                    <asp:RadioButton ID="rbSurgicalChecklistNo" runat="server" GroupName="optSurgicalChecklist" Text="No" />
                                                                    <asp:RadioButton ID="rbSurgicalChecklistYes" runat="server" GroupName="optSurgicalChecklist" Text="Yes" />
                                                                    <asp:HiddenField ID="WhoCheckHidden" runat="server" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div id="buttonsdiv1" style="height: 10px; padding-top: 10px;">
                                                                        <span style="float: left; padding-left: 150px; padding-right: 15px">
                                                                            <telerik:RadButton ID="WhoCheckSave" runat="server" Text="Save" Skin="WebBlue" OnClick="WhoCheckSave_Click" />
                                                                        </span>
                                                                        <span style="float: left">
                                                                            <telerik:RadButton ID="WhoCheckCancel" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeSurgicalChecklistWindow" />
                                                                        </span>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                </telerik:RadWindow>

                                                <telerik:RadWindow ID="ProcNotCarriedOutRadWindow" Modal="true" runat="server" Title="Procedure NOT carried out"
                                                    KeepInScreenBounds="true" Width="500px" Height="350px" VisibleStatusbar="false" ShowContentDuringLoad="false" Skin="Metro">
                                                    <ContentTemplate>
                                                        <div class="abnorHeader">Reason the procedure was NOT carried out:</div>
                                                        <div style="padding: 1em; margin-bottom: 1em;" id="ProcNotCarriedOutRadWindowDiv">
                                                            <div style="width: 90%; padding: 1em; border: 1px solid black; border-radius: 0px; margin: 1em; box-sizing: content-box;">
                                                                <label>
                                                                    <input type="radio" name="ProcNotCarriedOut" class="procNotCarriedOutOption" value="1" onclick="SetNewPPText()" />&nbsp;Patient DNA</label><br />
                                                                <label>
                                                                    <input type="radio" name="ProcNotCarriedOut" class="procNotCarriedOutOption" value="2" onclick="SetNewPPText()" />&nbsp;Patient Cancelled</label><br />
                                                                <label>
                                                                    <input type="radio" name="ProcNotCarriedOut" class="procNotCarriedOutOption" value="3" onclick="SetNewPPText()" />&nbsp;Hospital Cancelled</label><br />

                                                                <input type="checkbox" id="chkPatientDNA_Text" name="chkPatientDNA_Text" value="combine">
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
                                                <%--<telerik:RadWindow RenderMode="Lightweight" runat="server" ID="RadWindow_ContentTemplate" RestrictionZoneID="ContentTemplateZone"
                                                    Modal="true" Width="340px" Height="300px" Overlay="true" Title="Upload PDF for Patient"
                                                    style="align-content: center;" CenterIfModal="true" OffsetElementID="main" OnClientShow="setCustomPosition">--%>
                                                <telerik:RadWindow RenderMode="Lightweight" runat="server" ID="RadWindow_ContentTemplate"
                                                    Modal="true" Width="340px" Height="300px" Overlay="true" Title="Upload PDF for Patient" Top="500px"
                                                    Style="align-content: center;" CenterIfModal="true" OffsetElementID="main" OnClientShow="setCustomPosition">
                                                    <ContentTemplate>
                                                        <p class="contText" style="font-weight: bold">
                                                            Select PDF to upload into SE:
                                                        </p>
                                                        <asp:FileUpload ID="FileUpload1" runat="server" SkinID="Web20" CssClass="addkey_btn" />
                                                        <%--<div class="contButton">
                                                            <asp:TextBox ID="Textbox1" runat="server"></asp:TextBox>
                                                        </div>--%>
                                                        <p class="contText" style="font-weight: bold">
                                                            Procedure Date:
                                                        
                                                            <div class="contButton">
                                                                <telerik:RadDatePicker ID="ProcedureDateRadDatePicker" runat="server"
                                                                    EnableTyping="false" Width="200" Skin="Metro" CssClass="RadPicker_Default"
                                                                    Overlay="true" Style="z-index: 9999 !important;" ZIndex="9999" />
                                                            </div>
                                                        </p>
                                                        <p class="contText" style="font-weight: bold">
                                                            Description:
                                                        </p>
                                                        <div class="contButton">
                                                            <asp:TextBox ID="ProcedureDescriptionTextBox" runat="server" /><br />
                                                            <br />
                                                        </div>
                                                        <p>
                                                            <div class="contButton">
                                                                <asp:Button ID="SaveFile" Text="Upload File" runat="server" OnClick="SaveFile_Click" />
                                                                <telerik:RadButton ID="Cancel" Text="Cancel" runat="server" OnClientClicked="CloseWindowUpdate"
                                                                    Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="false" />
                                                            </div>
                                                        </p>
                                                    </ContentTemplate>
                                                </telerik:RadWindow>
                                                <%--<telerik:RadWindow RenderMode="Lightweight" runat="server" ID="DeleteProcedureRadWindow_ContentTemplate" RestrictionZoneID="ContentTemplateZone"
                                                    Modal="true" Width="340px" Height="340px" CenterIfModal="true" Overlay="true" Title="Delete Procedure from Patient"
                                                    style="align-content: center;" Left="200px">--%>
                                                <telerik:RadWindow RenderMode="Lightweight" runat="server" ID="DeleteProcedureRadWindow_ContentTemplate"
                                                    Modal="true" Width="340px" Height="300px" CenterIfModal="true" Overlay="true" Title="Delete Procedure from Patient"
                                                    Style="align-content: center;" Top="500px">
                                                    <ContentTemplate>
                                                        <p class="contText" style="font-weight: bold;">
                                                            <asp:Label ID="RemoveProcedureTypeLabel" runat="Server" Width="250"></asp:Label>
                                                        </p>
                                                        <telerik:RadTextBox ID="RemoveProcedureTypeTextBox" runat="server" ReadOnly="true" Width="250"
                                                            Style="border-color: none; border-style: hidden;" />

                                                        <p class="contText" style="font-weight: bold;">
                                                            Procedure Date:                                                        
                                                        </p>
                                                        <div class="contButton">
              
                                                            <asp:TextBox ID="RemoveProcedureDateRadDatePicker" runat="server"
                                                                EnableTyping="false" ReadOnly="true" Overlay="true" Width="250" ZIndex="9997"
                                                                Style="border-color: none; font-size: 12px; border-style: hidden;" />

                                                        </div>
                                                        <p class="contText" style="font-weight: bold;">
                                                            Reason:    
                                                        </p>
                                                        <telerik:RadTextBox ID="RemoveProcedureReasonRadTextBox" runat="server" Width="250"
                                                            Style="border-color: black;" />
                                                        <br />
                                                        <br />
                                                        <p>
                                                            <div class="contButton">
                                                                <asp:Button ID="RemovePDFButton" Text="Remove File" runat="server" OnClick="RemovePDFFile_Click" />
                                                                <telerik:RadButton ID="RemovePDFCancelButton" Text="Cancel" runat="server"
                                                                    OnClientClicked="CloseWindowDelete" Icon-PrimaryIconCssClass="telerikCancelButton"
                                                                    AutoPostBack="false" />
                                                            </div>
                                                        </p>
                                                    </ContentTemplate>
                                                </telerik:RadWindow>

                                                <%--<telerik:RadWindow RenderMode="Lightweight" runat="server" ID="RadWindow_NavigateUrl" 
                                                    Modal="true" RestrictionZoneID="NavigateUrlZone" Width="340px">
                                                </telerik:RadWindow>--%>
                                                <%--<telerik:RadWindow RenderMode="Lightweight" runat="server" ID="RadWindow_NavigateUrl" 
                                                    Modal="true" Width="340px">
                                                </telerik:RadWindow>--%>
                                            </Windows>
                                        </telerik:RadWindowManager>

                                    </div>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView runat="server" ID="ViewOrderCommsPageView">
                                <div>
                                    <div class="text">
                                        <table>
                                            <tr>
                                                <td styel="width:20%"><b>View Orders</b></td>
                                                <td style="font-size: small; text-align: right; width: 80%"></td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div id="OrderCommsDetailsDiv" class="divboxshadow" style="height: 450px; width: 720px; margin: 5px 10px 5px 10px; overflow-y: scroll;">
                                        <table border="0" style="width: 100%; vertical-align: top!important; padding: 0px 0px 0px 0px;" class="forceMetroSkin">
                                            <tr>
                                                <td style="vertical-align: top!important;">
                                                    <h3 class="reportheader">Order Details</h3>
                                                    <table border="0" style="padding: 0px 0px 0px 0px;">
                                                        <tr>
                                                            <td colspan="5">
                                                                <hr class="hairlinehr" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width: 200px;">Order Number:
                                                            </td>
                                                            <td style="width: 90px;">
                                                                <asp:Label runat="server" ID="lblOrderNo" Font-Bold="true"></asp:Label>
                                                            </td>
                                                            <td style="width: 50px;">&nbsp;</td>
                                                            <td style="width: 80px;"></td>
                                                            <td style="width: 90px;"></td>
                                                        </tr>
                                                        <tr>
                                                            <td>Order Date:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblOrderDate"></asp:Label>
                                                            </td>
                                                            <td rowspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                            <td>Date Raised:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblDateRaised"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Date Received:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblDateReceived"></asp:Label>
                                                            </td>
                                                            <td>Due Date:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblDueDate"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Order Source:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblOrderSource"></asp:Label>
                                                            </td>
                                                            <td>Location:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblLocation"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Ward:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblWard"></asp:Label>
                                                            </td>
                                                            <td>Bed:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblBed"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Referral Consultant:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblReferralConsultantName"></asp:Label></td>
                                                            <td>Ref Cons Speciality:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblReferralConsultantSpeciality"></asp:Label></td>
                                                        </tr>
                                                        <tr>
                                                            <td>Referral Hospital:</td>
                                                            <td colspan="4">
                                                                <asp:Label runat="server" ID="lblReferralHospitalName"></asp:Label></td>
                                                        </tr>
                                                        <tr>
                                                            <td>Order Hospital:</td>
                                                            <td colspan="2"></td>
                                                            <td>Priority:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblPriority"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td>Procedure Type:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblProcedureType"></asp:Label>
                                                            </td>
                                                            <td>&nbsp;</td>
                                                            <td>Order Status:</td>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblOrderStatus"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Rejection Reason:</td>
                                                            <td colspan="4">
                                                                <asp:Label runat="server" ID="lblRejectionReason"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Rejection Comments: </td>
                                                            <td colspan="4">
                                                                <asp:Label runat="server" ID="lblRejectionComments"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <h3 class="reportheader">Clinical History Notes:</h3>
                                                                <hr class="hairlinehr" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <asp:Label runat="server" ID="lblClinicalHistory"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <h3 class="reportheader">Questions & &nbsp;Answers:</h3>
                                                                <hr class="hairlinehr" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <asp:Repeater ID="rptQuestionsAnswers" runat="server">
                                                                    <HeaderTemplate>
                                                                        <table style="padding: 10px; width: 100%;" border="0">
                                                                            <tr>
                                                                                <td></td>
                                                                            </tr>
                                                                    </HeaderTemplate>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td>
                                                                                <b>Question : </b>
                                                                                &nbsp;&nbsp;
                                                    <asp:Label ID="lblQuestion" runat="server" Text='<%#Eval("Question") %>'></asp:Label>
                                                                                <br />
                                                                                &nbsp;<br />
                                                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Answer: &nbsp;<%#Eval("Answer") %><br />
                                                                            </td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                    <FooterTemplate>
                                                                        </table>
                                                                    </FooterTemplate>
                                                                </asp:Repeater>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <h3 class="reportheader">Previous Procedures History:</h3>
                                                                <hr class="hairlinehr" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <asp:Repeater ID="rptPrevHistory" runat="server">
                                                                    <HeaderTemplate>
                                                                        <table style="padding: 10px; width: 100%;" border="0">
                                                                            <tr>
                                                                                <td></td>
                                                                            </tr>
                                                                    </HeaderTemplate>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td>
                                                                                <%#Eval("ProcedureDate") %>
                                                                            </td>
                                                                            <td>
                                                                                <%#Eval("ProcedureType") %>
                                                                            </td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                    <FooterTemplate>
                                                                        </table>
                                                                    </FooterTemplate>
                                                                </asp:Repeater>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </telerik:RadPageView>

                        <telerik:RadPageView runat="server" ID="NewNurseModulePageView" Selected="false" Scrolling="y">
                              <div style="margin: -4px -7px;width: 100% !important;" class="new_preassessment">
                                  <asp:PlaceHolder ID="NurseModuleDynamicControlPlaceHolder" runat="server"></asp:PlaceHolder>
                                  <div class="text">
                                      <table style="width: 100%;">
                                          <tr>
                                              <td style="width: 30%" id="nurseModuleTitle" runat="server"><b>New Nursing Module</b>&nbsp;&nbsp;<asp:Label ID="Label5" runat="server" Text="" ForeColor="Blue"></asp:Label></td>
                                              <td style="font-size: small; text-align: right; width: 70%">
                                                  <img src="../Images/NEDJAG/Mand.png" />Mandatory&nbsp;&nbsp;</td>
                                            </tr>
                                      </table>
                                      </div>
                                     <div id="frameNewProc2" style="margin: -5px 18px;">
                                      <table border="0" class="lblText" id="table2" runat="server" cellspacing="3" cellpadding="0" style="width: 890px;">
                                         <tr>
                                             <td><asp:HiddenField ID="NurseModuleHiddenField" runat="server" /></td>
                                             <td><asp:HiddenField ID="IsNewNurses" runat="server" /></td>
                                         </tr>

                                          <tr>
                     
                                              <td style="width: 50%;margin-left:10px">
                                                   <span>Start time</span>
          
                                                   <telerik:RadDateInput style="margin-left: 53px;width: 100px !important"  ID="NurseRadDateInput" runat="server"  DisplayDateFormat="dd/MM/yyyy" OnClientDateChanged="onDateChanged"  CssClass="procedure-start-date" />
                                                   <telerik:RadTimePicker style="margin-left: 10px;width: 75px" TimeFormat="HH" ID="NurseRadTimePicker" runat="server" Enabled="true"  AutoPostBack="true" 
                                                            OnSelectedDateChanged="NurseRadTimePicker_SelectedDateChanged" CssClass="procedure-start-time">
                                                   </telerik:RadTimePicker>
                                                   <telerik:RadButton ID="NurseTimeNow" runat="server" Text="Now" AutoPostBack="true"  OnClick="NurseTimeNow_Click" />
                                               </td>
                                          </tr>
                                          <tr>
                 
                                          <td style="width: 100%;">
                                              <span style="display: inline-block; vertical-align: middle;">Procedure</span>
                                              <telerik:RadComboBox 
                                                  ID="NurseModuleProcedureTypeRadComboBox" 
                                                  runat="server" 
                                                  checkboxes="true"
                                                  OnSelectedIndexChanged="NurseModuleProcedureTypeRadComboBox_SelectedIndexChanged" 
                                                  AutoPostBack="true" 
                                                  Skin="Windows7" 
                                                  EnableCheckAllItemsCheckBox="true"  
                                                  style="display: inline-block !important; margin-left: 50px;margin-top: 5px" />
                                          </td>
                                          </tr>
                                      </table>
                                         <div style="padding-bottom: 7px; margin-top: 28px">
                                      <asp:Repeater ID="NurseModuleSectionRepeater" runat="server" OnItemDataBound="NurseModuleSectionsRepeater_ItemDataBound">
                                          <HeaderTemplate>
                                              <table class="DataBoundTable" id="nurseModuleTableId" cellpadding="3" cellspacing="3" style="width: 100%">
                                          </HeaderTemplate>
                                          <ItemTemplate>
                                              <tr>
                                                  <td colspan="2">
                                                      <div class="control-section-header abnorHeader" id="sectionHeader" runat="server"><%# Eval("SectionName") %>&nbsp; </div>
                                                  </td>
                                              </tr>
                                              <asp:Repeater ID="NurseModuleQuestionsRepeater" runat="server" OnItemDataBound="NurseModuleQuestionRepeater_ItemDataBound">
                                                  <ItemTemplate>
                                                      <tr>
                                                          <td style="vertical-align: top; width: 65%;">
                                                              <asp:HiddenField ID="NurseModuleQuestionIdHiddenField" runat="server" Value='<%#Eval("QuestionId") %>'/>
                                                                     <div style="margin-left: 10px; display: inline-block;">
                                                                              <asp:Image ID="PreQuestionMandatoryImage" runat="server" ImageUrl="../Images/NEDJAG/Mand.png" AlternateText="Mandatory Field" />
                                                                              <telerik:RadLabel runat="server" ID="lblQuestion" Text='<%#Eval("Question") %>' />
                                                                       </div>
                                                          </td>
                                                          <td style="vertical-align: top; width: 35%;">
                                                              <asp:HiddenField ID="NurseModuleAnswerIdHiddenField" runat="server" Value='<%#Eval("AnswerId") %>'/>
                                                               <telerik:RadComboBox ID="NurseModuleDropdownOptionsRadComboBox" runat="server" Skin="Metro" CssClass="nurse-module-dropdown-combobox" OnClientSelectedIndexChanged="onNurseModuleComboBoxSelectionChange" data-itemid='<%#Eval("QuestionId") %>' data-answerid='<%# Eval("AnswerId") %>'></telerik:RadComboBox>
                                      
                                                              <asp:RadioButtonList ID="NurseModuleQuestionOptionRadioButton" runat="server" AutoPostBack="false" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="nurse-module-question-option" data-itemid='<%#Eval("QuestionId") %>' data-answerid='<%# Eval("AnswerId") %>' Style="margin-right: 10px;">
                                                                  <asp:ListItem Text="Yes" Value="1" style="margin-right: 10px;" />
                                                                  <asp:ListItem Text="No" Value="0" style="margin-right: 10px;" />
                                                              </asp:RadioButtonList>
                                                              <telerik:RadTextBox ID="NurseModuleQuestionAnswerTextBox" runat="server" Skin="Metro" CssClass="nurse-module-question-input" data-itemid='<%#Eval("QuestionId") %>' data-answerid='<%# Eval("AnswerId") %>' />
                                                          </td>
                                                      </tr>
                                                  </ItemTemplate>
                                              </asp:Repeater>
                                          </ItemTemplate>
                                          <FooterTemplate>
                                              </table>
                                          </FooterTemplate>
                                      </asp:Repeater>
                                      </div>
                                      </div>
                                       <table>
                                             <tr>
                                             <td colspan="12">
                                                 <div class="preAssessBtn" id="NurseCreatedDiv" runat="server">
            
                                                     <telerik:RadButton ID="CreateNurseModuleProcedureButton" runat="server" Text="Save Nursing Module" CssClass="RadButton RadButton_Metro rbButton rbRounded rbPrimaryButton"
                                                         Skin="Metro" Font-Bold="true" Height="20px" OnClientClicking="validateNurseQuestions" AutoPostBack="false"/>
                                                     <div style="display: none">
                                                         <telerik:RadButton ID="CreateNurseModuleProcedureButton1" runat="server" Text="Create Procedure" OnClick="CreateNurseModuleProcedureButton1_Click"
                                                             Skin="Metro" Font-Bold="true" Height="20px"  AutoPostBack="true"/>
                                                   </div>
                                              </div>
                                             </td>
                                         </tr>
                                     </table>
 
                              </div>
                        </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </telerik:RadPane>

            </telerik:RadSplitter>
        </telerik:RadPane>
    </telerik:RadSplitter>
</div>


<telerik:RadAjaxManagerProxy ID="RadAjaxManagerProxy1" runat="server">
    <AjaxSettings>
        <telerik:AjaxSetting AjaxControlID="ProductRadioButtonList">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="ProcTypeRadComboBox" />
                <telerik:AjaxUpdatedControl ControlID="ProductRadioButtonList" />
            </UpdatedControls>
        </telerik:AjaxSetting>
        <%-- <telerik:AjaxSetting AjaxControlID="ConsultantComboBox">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="SpecialityRadComboBox" />
                <telerik:AjaxUpdatedControl ControlID="HospitalComboBox" />
            </UpdatedControls>
        </telerik:AjaxSetting>

        <telerik:AjaxSetting AjaxControlID="SpecialityRadComboBox">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="ConsultantComboBox" />
                <telerik:AjaxUpdatedControl ControlID="HospitalComboBox" />
                <telerik:AjaxUpdatedControl ControlID="SpecialityRadComboBox" />
            </UpdatedControls>
        </telerik:AjaxSetting>--%>

        <telerik:AjaxSetting AjaxControlID="AddNewWardSaveRadButton">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="WardComboBox" />
            </UpdatedControls>
        </telerik:AjaxSetting>

        <telerik:AjaxSetting AjaxControlID="WhoCheckSave">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="WhoCheckSave" />
            </UpdatedControls>
        </telerik:AjaxSetting>
        <telerik:AjaxSetting AjaxControlID="ThumbnailRotator">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="PhotoViewer" LoadingPanelID="RadAjaxLoadingPanel1" UpdatePanelRenderMode="Inline" />
                <telerik:AjaxUpdatedControl ControlID="VideoViewer" LoadingPanelID="RadAjaxLoadingPanel1" UpdatePanelRenderMode="Inline" />
                <telerik:AjaxUpdatedControl ControlID="ImageDescriptionLabel" UpdatePanelRenderMode="Inline" />
            </UpdatedControls>
        </telerik:AjaxSetting>
        <telerik:AjaxSetting AjaxControlID="PhotoViewer">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="PhotoViewer" LoadingPanelID="RadAjaxLoadingPanel1" UpdatePanelRenderMode="Inline" />
            </UpdatedControls>
        </telerik:AjaxSetting>
    </AjaxSettings>
</telerik:RadAjaxManagerProxy>
<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
</telerik:RadAjaxLoadingPanel>

<telerik:RadWindowManager ID="PatientProcedureRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="UnlockProcedureWindow" runat="server" Modal="true" ReloadOnShow="False" KeepInScreenBounds="false" Width="700px" Height="210px" VisibleStatusbar="false" VisibleOnPageLoad="false" EnableViewState="false" Title="Edit history" BackColor="#ffffcc">
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

                            <telerik:RadButton ID="YesRadButton" runat="server" Text="Yes" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" AutoPostBack="false" Style="margin-right: 20px;" OnClientClicked="unlockProcedure" />
                            <telerik:RadButton ID="PopUpCloseRadButton" runat="server" Text="No" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="unlockPopUpClose" Font-Size="Large" />
                        </td>

                    </tr>
                </table>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
<%--Added by rony tfs-3059--%>
<telerik:RadWindowManager ID="DeleteReportRadWindowManager" runat="server" ShowContentDuringLoad="false" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="DeleteReportDetailsWindow" runat="server" Height="200" Width="680" VisibleStatusbar="false">
            <ContentTemplate>
                <div id="bookingDetailsDiv" runat="server">                    
                    <fieldset>
                        <legend>Why is this being deleted</legend>
                        <table>
                            <tr>
                                <td colspan="3">
                                    <telerik:RadTextBox ID="DeleteReportTextBox" runat="server" TextMode="MultiLine" Width="630px" height="70px"/>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                    <div style="padding-top: 10px;">
                        <telerik:RadButton ID="SaveDeleteReportRadButton" runat="server" Text="Save" Skin="Metro" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikSaveButton"  OnClientClicked="deleteReportData" />
                        <telerik:RadButton ID="CancelDeleteReportRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="deleteReportCancel" />
                    </div>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
<telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">
        //if (Telerik.Web.Browser.ie && (Telerik.Web.Browser.version == 10 || Telerik.Web.Browser.version == 11)) {
        //Telerik.Web.UI.RadAsyncUpload.Modules.FileApi.isAvailable = function () { return false; }
        //Telerik.Web.UI.RadAsyncUpload.Modules.Silverlight.isAvailable = function () { return false; }
        //}
        
        var isNurseChanges = false;
        var isPreAssessChanges = false;
        $(document).on('change', '.assessment-question-option', function ()
        {
            var questionId = $(this).attr('data-itemid');
            var answerId = $(this).attr('data-answerid');
            var optionAnswer = $(this).closest('.assessment-question-option').find('input[type="radio"]:checked').val(); // Get the selected value
            var textAnswer = ($(this).closest('tr').find('.assessment-question-input').length === 0) ? '' : $(this).closest('tr').find('.assessment-question-input').val();
            addRedBorderForRequiredField();
            isPreAssessChanges = true;
            savePreAssessmentQuestions(questionId, answerId, optionAnswer, textAnswer, '');
        });

        $(document).on('focusout', '.assessment-question-input', function ()
        {
            isPreAssessChanges = true;
            var questionId = $(this).attr('data-itemid');
            var textAnswer = $(this).val();
            var answerId = $(this).attr('data-answerid');
            var dropdownAnswer = $(this).closest('tr').find('.assessment-dropdown-combobox').length === 0 ? '': $(this).closest('tr').find('.assessment-dropdown-combobox').data("telerikComboBox").get_value();
            addRedBorderForRequiredField();
            savePreAssessmentQuestions(questionId, answerId, undefined, textAnswer, dropdownAnswer);
        });


        $(document).on('change', '.nurse-module-question-option', function () {
            isNurseChanges = true;
            var questionId = $(this).attr('data-itemid');
            var answerId = $(this).attr('data-answerid');
            var optionAnswer = $(this).closest('.nurse-module-question-option').find('input[type="radio"]:checked').val();
            var textAnswer = ($(this).closest('tr').find('.nurse-module-question-input').length === 0) ? '' : $(this).closest('tr').find('.nurse-module-question-input').val();
            addRedBorderForNurseRequiredField();
            saveNurseModuleAnswer(questionId, answerId, optionAnswer, textAnswer, '');
        });

        $(document).on('focusout', '.nurse-module-question-input', function () {
            isNurseChanges = true;
            var questionId = $(this).attr('data-itemid');
            var textAnswer = $(this).val();
            var answerId = $(this).attr('data-answerid');
            var dropdown = $(this).closest('tr').find('.nurse-module-dropdown-combobox');
            var dropdownAnswer = '';
            if (dropdown.length > 0) {
                var dropdownId = dropdown.attr('id'); 
                var comboBox = $find(dropdownId);  
                if (comboBox != null) {
                     dropdownAnswer = comboBox.get_value();  
                }
            }
            addRedBorderForNurseRequiredField();
            saveNurseModuleAnswer(questionId, answerId, undefined, textAnswer, dropdownAnswer);
        });
        $(document).ready(function () {

            Sys.Application.add_load(function () {
                bindJQEvents();
            });
        });

        function patientConcentcombox() {
            newProcedureInitiated = true;
            $('#<%= ConsentRadioButtonList.ClientID %> input[type=radio]').change(function () {
                if ($(this).val() === '1') {
                    $('#<%= PatientConsentId.ClientID %>').show();
                    $('#<%= PatientConsentOtherTextBox.ClientID %>').hide();
                }
                else {
                    $('#<%= PatientConsentId.ClientID %>').hide();
                    $find('<%=PatientConsentOtherTextBox.ClientID%>').set_value('');
                }
                $find('<%= PatientConsentRadComboBox.ClientID %>').clearSelection();
            });

            $('#<%= PatientConsentRadComboBox.ClientID %>').on('change', function () {
                if ($(this).val() === 'Other') {
                    $('#<%= PatientConsentOtherTextBox.ClientID %>').show();
                } else {
                    $find('<%=PatientConsentOtherTextBox.ClientID%>').set_value('');
                    $('#<%= PatientConsentOtherTextBox.ClientID %>').hide();
                }
            });
        }
        function startdatetimenow() {
            var currentdate = new Date();

            var currentdate = new Date();
            $find('<%=ProcedureStartDateRadTimeInput.ClientID%>').set_selectedDate(currentdate);
            var hours = currentdate.getHours();

            var timeView = $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView()
            if (timeView != null) {
                timeView.setTime(hours,
                    currentdate.getMinutes(),
                    currentdate.getSeconds(),
                    currentdate);
            }
        }
        function startNurseDatetimenow()
        {
            var currentdate = new Date();

            var currentdate = new Date();
            $find('<%=NurseRadDateInput.ClientID%>').set_selectedDate(currentdate);
            var hours = currentdate.getHours();

                    var timeView = $find('<%=NurseRadTimePicker.ClientID%>').get_timeView()
                    if (timeView != null) {
                        timeView.setTime(hours,
                            currentdate.getMinutes(),
                            currentdate.getSeconds(),
                            currentdate);
                    }
        }
        function onNurseModuleComboBoxSelectionChange(sender, eventArgs) {
            var comboBox = sender;
            isNurseChanges = true;

            var dropdownAnswer = comboBox.get_value();
            var row = $(comboBox.get_element()).closest('tr');
            var optionAnswer = row.find('.nurse-module-question-option input:checked').val();
            var textAnswer = row.find('.nurse-module-question-input').val();
            var answerId = sender.get_attributes().getAttribute("data-qanswerid");
            var questionId = sender.get_attributes().getAttribute("data-questionid");
            addRedBorderForNurseRequiredField();
            saveNurseModuleAnswer(questionId, answerId, optionAnswer, textAnswer, dropdownAnswer);
        }
        function saveNurseModuleAnswer(questionId, answerId, optionAnswer, freeTextAnswer, dropdownAnswer)
        {
            var obj = {};
            obj.nurseModuleId = $('#<%=NurseModuleHiddenField.ClientID%>').val();
            obj.questionId = parseInt(questionId);
            obj.optionAnswer = (optionAnswer == undefined) ? -1 : optionAnswer;
            obj.freeTextAnswer = (freeTextAnswer == undefined) ? '' : freeTextAnswer;
            obj.answerId = parseInt(answerId);
            obj.dropdownAnswer = (dropdownAnswer == undefined) ? '' : dropdownAnswer;
            $.ajax({
                type: "POST",
                url: "Default.aspx/SaveNurseModuleAnswer",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                },
                error: function (x, y, z) {

                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }
        function updateNurseProcedureTimings()
        {
            var startDate = $find('<%=NurseRadDateInput.ClientID%>').get_selectedDate();
                     var startTime = $find('<%=NurseRadTimePicker.ClientID%>').get_timeView().getTime();

                     if (startTime != null) {

                         startDate.setHours(startTime.getHours());
                         startDate.setMinutes(startTime.getMinutes());
                     }
                     else {
                         startDate = null;
                     }

         }
        function updateProcedureTimings() {
            var startDate = $find('<%=ProcedureStartDateRadTimeInput.ClientID%>').get_selectedDate();
            var startTime = $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView().getTime();

            if (startTime != null) {

                startDate.setHours(startTime.getHours());
                startDate.setMinutes(startTime.getMinutes());
            }
            else {
                startDate = null;
            }

        }
        function onDateChanged(sender, eventArgs) {
            var selectedDate = sender.get_selectedDate(); 
            $find("<%=CreateNurseModuleProcedureButton1.ClientID %>").click();

        }
        function onPreAssessDateChanged(sender, eventArgs)
        {
            var selectedDate = sender.get_selectedDate();
            $find("<%=CreatePreAssessmentProcedureButton1.ClientID %>").click();

         }
        function onComboBoxSelectionChange(sender, eventArgs) {
            var comboBox = sender;

            newProcedureInitiated = true;
            var dropdownAnswer = comboBox.get_value();
            var row = $(comboBox.get_element()).closest('tr');
            var optionAnswer = row.find('.assessment-question-option input:checked').val();
            var textAnswer = row.find('.assessment-question-input').val();
            var answerId = sender.get_attributes().getAttribute("data-qanswerid");
            var questionId = sender.get_attributes().getAttribute("data-questionid");
            addRedBorderForRequiredField();
            savePreAssessmentQuestions(questionId, answerId, optionAnswer, textAnswer, dropdownAnswer);
        }

        function getComboboxSelectedItem(sender, args) {
            var selectedItem = args.get_item();
            var answerId = sender.get_attributes().getAttribute("data-qanswerid");
            var questionId = sender.get_attributes().getAttribute("data-questionid");
            var optionAnswer = $(sender.get_element()).closest('tr').find('.assessment-question-option input:checked').val();
            var textAnswer = $(sender.get_element()).closest('tr').find('.assessment-question-input').val();
            savePreAssessmentQuestions(questionId, answerId, optionAnswer, textAnswer)
        }
        function savePreAssessmentQuestions(questionId, answerId, optionAnswer, freeTextAnswer, dropdownAnswer) 
        {
            var obj = {};
            obj.preAssessmentId = $('#<%=PreAssessmentHiddenField.ClientID%>').val();
            obj.questionId = parseInt(questionId);
            obj.optionAnswer = (optionAnswer == undefined) ? -1 : optionAnswer;
            obj.freeTextAnswer = (freeTextAnswer == undefined) ? '' : freeTextAnswer;
            obj.answerId = parseInt(answerId);
            obj.dropdownAnswer = (dropdownAnswer == undefined) ? '' : dropdownAnswer;
            $.ajax({
                type: "POST",
                url: "Default.aspx/SavePreAssementQuestion",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    /* setRehideSummary();*/
                },
                error: function (x, y, z) {
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }
        function unlockPopUpClose() {
              $find("<%=UnlockProcedureWindow.ClientID%>").close();
        }
        function deleteReportCancel() {
            $find("<%=DeleteReportDetailsWindow.ClientID%>").close();
       }
        function bindJQEvents() {
            //newProcedureInitiated = true;
            $('#<%=PatientNotesRadioButtonList.ClientID%> input').on('change', function () {
                var selectedItem = $('#<%=PatientNotesRadioButtonList.ClientID%> input:checked');
                var notesAvailable = (selectedItem.val() == '0' ? false : true);

                if (notesAvailable == false) {
                    $("#<%= ReferralLetterTD.ClientID%>").show();
                 }
                 else {
                     $("#<%= ReferralLetterTD.ClientID%>").hide();
                }
            });
        }

        $(function () {

            /*
            * this swallows backspace keys on any non-input element.
            * stops backspace -> back
            */
            var rx = /INPUT|SELECT|TEXTAREA/i;

            $(document).bind("keydown keypress", function (e) {
                if (e.which == 8) { // 8 == backspace
                    if (!rx.test(e.target.tagName) || e.target.disabled || e.target.readOnly) {
                        e.preventDefault();
                    }
                }
            });

            $('#RemovePDFCancelButton').on('click', function (e) {
                e.preventDefault();
            });


        });

        var docURL = document.URL;
        var webMethodLocation = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Default.aspx/";

        var hospId = '<%= Session("OperatingHospitalID") %>';
        var RoomId = '<%= Session("RoomId") %>';

        function loadImagePorts() {
            $.ajax({
                type: "POST",
                url: webMethodLocation + "GetPCImagePort",
                data: JSON.stringify({ RoomId: RoomId, operatingHospitalId: parseInt(hospId) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d != null) {
                        var res = JSON.parse(data.d);
                        $('#<%=ImagePortNameLabel.ClientID%>').text(res[0].PortName);
                        $('#<%=ImagePortIdHiddenField.ClientID%>').val(res[0].ImagePortId);
                    }
                    else {
                        $('#<%=ImagePortNameLabel.ClientID%>').text("None");
                        $('#<%=ImagePortIdHiddenField.ClientID%>').val("");
                    }
                },
                error: function (jqXHR, textStatus, data) {
                    alert(jqXHR.responseJSON.Message);
                }
            });
        }


        $(document).ready(function () {
            PatStatusClicked();
            //loadImagePorts();
            //nurseValidation();            
        });

        //## function to show/hide category option controls based on user selection
        function setCategoryOptions(sender, args) {
            <%--'Added by rony tfs-3489--%>
            var input = sender.get_inputDomElement();
            input.style.backgroundImage = "url(" + args.get_item().get_imageUrl() + ")";
            input.style.backgroundRepeat = "no-repeat";
            input.style.textIndent = "20px";
            var divName = sender.get_text().substring(0, 4);
            $("[id*='divCategory_']").hide();  //## Hide all three option sets.. Unhide them later as per request!
            if ($.inArray(divName.toLowerCase(), ['emer', 'open', 'elec']) >= 0) {
                $("[id*='divCategory_" + divName + "']").show();
            }
        }
        <%--'Added by rony tfs-3489--%>
        function OnCategoryOptionsLoad(sender, args) {
            if (!sender.get_selectedItem()) {
                return false;
            } else {
                var input = sender.get_inputDomElement();
                input.style.backgroundImage = "url(" + sender.get_selectedItem().get_imageUrl() + ")";
                input.style.backgroundRepeat = "no-repeat";
                input.style.textIndent = "20px";
            }
        }
        function PatStatusClicked() {
            var checked_radio = $("#<%= PatStatusRadioButtonList.ClientID%> input:checked");
            //var value = checked_radio.val();
            var text = checked_radio.closest("td").find("label").html();
            if (text != undefined && text != null) {
                //alert("Text: " + text + " Value: " + value);
                ToggleWard(text);
            }
        }


        function FixPageViewHeight() {
            var height = $(window).height();

            var multiPage = $find("<%=RMPPrevProcs.ClientID %>");
            if (multiPage != null) {
                var totalHeight = height - 42;
                multiPage.get_element().style.height = totalHeight + "px";
            }
        }

        var validateWard;
        function ToggleWard(selectedText) {
            var wardDiv1 = $("#<%= PatientWardCell1.ClientID%>");
            <%If Not CBool(Session("isERSViewer")) Then%>

            if ((selectedText != null) && (selectedText.indexOf("Inpatient") > -1)) {
                wardDiv1.show();
                validateWard = true;
            }
            else {
                wardDiv1.hide();
                $find('<%=WardComboBox.ClientID%>').clearSelection();
                validateWard = false;
            }
            <%End If%>
        }

        function openAddWardWindow() {
            var oWnd = $find("<%= AddNewWardRadWindow.ClientID%>");
            oWnd.show();
            return false;
        }
        function openChangeImageportMessage() {
            newProcedureInitiated = true;
            var ImagePort = $find('<%=ImagePortComboBox.ClientID%>')._text;
            if (ImagePort != "") {
                document.getElementById("ImagePortSelectedMessage").innerHTML = '<br />Please ensure you have selected the correct ImagePort. You have selected ImagePort <br /><br /> <h2>' + ImagePort + '</h2>';
                var oWnd = $find("<%= ChangeImageportMessage.ClientID%>");
                oWnd.show();
                return false;
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

        function closeChangeImageportMessage() {

            var oWnd = $find("<%= ChangeImageportMessage.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        function closeClearChangeImageportMessage() {
            $find('<%=ImagePortComboBox.ClientID%>').set_text("");
            var oWnd = $find("<%= ChangeImageportMessage.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        function closeAddWardWindow() {
            var oWnd = $find("<%= AddNewWardRadWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        function closeSurgicalChecklistWindow() {
            var oWnd = $find("<%= SurgicalChecklistRadWindow.ClientID%>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        //####### Procedure Not Carried Out Dialogue - events

        //function UpdatePreceduresDNA() {
        //    console.log("Going to invoke: PageMethods.ProcedureNotCarriedOut();");

        //    PageMethods.ProcedureNotCarriedOut("1234", "1", "Formatted DNA Text is here!", onSuccess, onFailed);
        //    function onSuccess(result) {
        //        //$("#lblResult").val(result.d);
        //        console.log("Sucess: " + result.d);
        //        alert("Result returned from: Function ProcedureNotCarriedOut_UpdateReason=> " + result.d);
        //    }
        //    function onFailed(jqXHR, textStatus, data) {                
        //        console.log("Failed: ProcedureNotCarriedOut_UpdateReason() ==> !\n\jqXHR: " + jqXHR + ". textStatus: " + textStatus); //
        //        //$("#lblResult").val(result.d);
        //        alert("Result returned from: Function ProcedureNotCarriedOut_UpdateReason=> " + jqXHR + "\n\n TextStatus: " + textStatus + "\n\ndata = " + data.d);
        //    }

        //    return false;
        //}

        //###   This will Update the fields in the ERS_Procedures Table! Procedures: DNA, DNACombined, PP_DNA
        function ProcNotCarriedOut_UpdateSelection() {
            //console.log("function ProcNotCarriedOut_UpdateSelection()");

            var selectedProcedureId = $('#selectedProcedureId').val();
            var selectedReasonId = $('.procNotCarriedOutOption:checked').val();
            var PP_DNA_Text = '';

            if (selectedReasonId == null) {
                $("#btnProcNotcarriedOutSubmit").attr("disabled", "disabled");
                //console.log("(selectedReasonId == null)");
                ("#ReasonNotSelectedErrorDiv").toggle('slow');
                return;
            }

            var chkShowPP_DNA_Text = document.getElementById('chkPatientDNA_Text');
            var result = chkShowPP_DNA_Text.checked;

            if ((result == true)) {
                PP_DNA_Text = $("#lblDNA_PP_Text").text();

            }



            var resultText = PageMethods.ProcedureNotCarriedOut_UpdateReason(selectedProcedureId, selectedReasonId, PP_DNA_Text, OnSuccess_UpdateReason, OnError_UpdateReason);

            UpdateProcedureNodeAtributeValues(selectedReasonId, PP_DNA_Text);   // Update the Procedure->Node.Attributes

            ProcNotCarriedOutCloseDialogueBox();
            //UpdateReasonByAjaxCall(selectedEpisodeNo, selectedProcedureId, selectedReasonId, isCombined, PP_DNA_Text);

            return false;

        }

        //### This will update the newly saved values for 'DNA Type' and 'PP_DNA Text' in the Node Attributes.. for later read- avoiding hitting the Database just for these two values!
        function UpdateProcedureNodeAtributeValues(dnaReason, ppText) {
            //selectedProcedureNode.get_attributes().attr()
            var tree = $find("<%= PrevProcsTreeView.ClientID%>");
            var nodeText = $('#selectedNodeText').val();
            var node = tree.findNodeByText(nodeText);

            node.get_attributes().setAttribute("DNA_Reason", dnaReason);
            node.get_attributes().setAttribute("DNA_Reason_PP_Text", ppText);
        }

        function UpdateReasonByAjaxCall(procedure, DNA_Reason, PP_DNA_Text) {
            // episodeNumber As String, ByVal procedureId As String, ByVal DNA_ReasonId As String, ByVal DNA_Combined As String, ByVal PP_DNA_Text As String
            var webMethodUrl = documentUrl.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/ProcedureNotCarriedOut_UpdateReason";
            var jsonData = JSON.stringify({
                procedureId: procedure,
                DNA_ReasonId: DNA_Reason,
                PP_DNA_Text: PP_DNA_Text
            });


            ///return; //#### do nothing
            $.ajax({
                type: "POST",
                url: webMethodUrl,
                data: jsonData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess_UpdateReason(data),
                error: OnError_UpdateReason(jqXHR, textStatus, data)
            });

        }


        function OnSuccess_UpdateReason(result) {

        }

        function OnError_UpdateReason(jqXHR, textStatus, data) {

        }

        function ProcNotCarriedOutCloseDialogueBox() {
            var oWnd = $find("<%= ProcNotCarriedOutRadWindow.ClientID%>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        //##### Update the PP_DNA text as the user selects diffrerent options for 'Procedures Not Carried out reason'
        function SetNewPPText() {
            var selectedReasonId = $('.procNotCarriedOutOption:checked').val();
            var selectedReasonText = $('.procNotCarriedOutOption:checked').parent().text();
            var PP_DNA_Text = '';
            var procName = $("#selectedProcedureType").val();

            //### Build the PP_DNA Text for ERS_ProceduresReporting
            if (selectedReasonId == '1')
                PP_DNA_Text = 'Patient DNA this procedure';
            else if (selectedReasonId == '2')
                PP_DNA_Text = 'Patient cancelled this procedure';
            else if (selectedReasonId == '3')
                PP_DNA_Text = 'Hospital cancelled this procedure';
            else
                PP_DNA_Text = selectedReasonId;


            PP_DNA_Text += ' and a ' + procName;

            $("#lblDNA_PP_Text").text(PP_DNA_Text);

            //$('#chkPatientDNA_Text').css('visibility', 'visible');
            $("#chkPatientDNA_Text").removeClass('hidden');  //## Initially will stay Hidden.. after selecting one of the options from Radio grouip- make it visible!
            $find("<%= btnProcNotcarriedOutSubmit.ClientID%>").set_enabled(true);

        }

        // 1, 'Independent (no trainer)'
        // 2, 'Was observed'
        // 3, 'Was assisted physically'  ListTypeComboBox
        function ListConsultantChanged() {
            newProcedureInitiated = true;
            //get GMC Code and set hidden variable
            var hiddenField = $('#<%=ListConsultantGMCHiddenField.ClientID%>');
            var userId = $find('<%=ListConsultantComboBox.ClientID%>').get_value();
            getGMCCode(hiddenField, userId);
            setEndoscopist1();
        }

        function Endo1Changed() {
            newProcedureInitiated = true;
            //get GMC Code and set hidden variable
            var hiddenField = $('#<%=Endo1GMCHiddenField.ClientID%>');
            var userId = $find('<%=Endo1ComboBox.ClientID%>').get_value();
            getGMCCode(hiddenField, userId);
            ddlComparisonValidation("endo");
            setEndoscopistRole();
        }

        function Endo2Changed() {
            newProcedureInitiated = true;
            //get GMC Code and set hidden variable
            var hiddenField = $('#<%=Endo2GMCHiddenField.ClientID%>');
            var userId = $find('<%=Endo2ComboBox.ClientID%>').get_value();
            getGMCCode(hiddenField, userId);
            ddlComparisonValidation("endo");
            setEndoscopistRole();
        }

        function setEndoscopistRole() {
            newProcedureInitiated = true;
            // Added by rony tfs-4175  
            setProcedurePoints($find('<%=ProcTypeRadComboBox.ClientID%>').get_value())


            var comboEndo1 = $find('<%=Endo1ComboBox.ClientID%>');
            if (comboEndo1 == undefined || comboEndo1 == null || comboEndo1.get_selectedItem() == null) return;
            var comboEndo1Val = comboEndo1.get_selectedItem().get_value();

            var comboEndo2 = $find('<%=Endo2ComboBox.ClientID%>');
            var comboEndo2Val = comboEndo2.get_selectedItem().get_value();
            var comboEndo1Role = $find('<%=Endo1RoleComboBox.ClientID%>');
            var comboEndo1RoleVal = comboEndo1Role.get_selectedItem().get_value();
            var comboEndo2Role = $find('<%=Endo2RoleComboBox.ClientID%>');
            var comboEndo2RoleVal = comboEndo2Role.get_selectedItem().get_value();

            var comboListType = $find('<%=ListTypeComboBox.ClientID%>');
            var comboListTypeVal = comboListType.get_selectedItem().get_value();

            enableComboItems(comboEndo1Role);
            enableComboItems(comboEndo2Role);
            $('#<%=Endoscopist1Label.ClientID%>').html("Endoscopist 1:");
            $('#<%=Endoscopist2Label.ClientID%>').html("Endoscopist 2:");
            if (comboEndo1Val != '' && comboEndo2Val != '') {
                if (comboEndo1Val == comboEndo2Val) {
                    setComboVal(comboEndo1Role, 1); //'Independent (no trainer)'
                    setComboVal(comboEndo2Role, 1); //'Independent (no trainer)'
                    disableComboItems(comboEndo1Role, 4);
                    disableComboItems(comboEndo2Role, 4);
                } else {
                    if (comboListTypeVal == 1) { //ListType is Service List
                        setComboVal(comboEndo1Role, 1); //'Independent (no trainer)'
                        setComboVal(comboEndo2Role, 1); //'Independent (no trainer)'
                        disableComboItems(comboEndo1Role, 4);
                        disableComboItems(comboEndo2Role, 4);
                    } else {
                        setComboVal(comboEndo1Role, 2); //'I observed'
                        setComboVal(comboEndo2Role, 2); //'Was observed'
                        disableComboItems(comboEndo1Role, 2);
                        disableComboItems(comboEndo2Role, 2);
                    }

                    if (comboListTypeVal != 1) { //Do not change Endoscopist labels if ListType is Service List
                        $('#<%=Endoscopist1Label.ClientID%>').html("TrainER:");
                        $('#<%=Endoscopist2Label.ClientID%>').html("TrainEE:");
                    }
                }
            } else {
                if (comboEndo1Val == '') {
                    setComboVal(comboEndo1Role, 0);
                } else {
                    setComboVal(comboEndo1Role, 1); //'Independent (no trainer)'
                }

                if (comboEndo2Val == '') {
                    setComboVal(comboEndo2Role, 0);
                } else {
                    setComboVal(comboEndo2Role, 1); //'Independent (no trainer)'
                }
                disableComboItems(comboEndo1Role, 4);
                disableComboItems(comboEndo2Role, 4);

            }
        }

        var vCounterToExit = 0;

        function changeEndoRole(sender, args) {
            newProcedureInitiated = true;
            if (vCounterToExit == 1) {
                vCounterToExit = 0;
                return;
            }
            if (sender._uniqueId.indexOf('Endo1') !== -1) {
                vCounterToExit = 1;
                setEndoscopist1RoleChanged();
            } else {
                vCounterToExit = 1;
                setEndoscopist2RoleChanged();
            }
        }

        function setEndoscopist1RoleChanged() {
            var comboEndo1Role = $find('<%=Endo1RoleComboBox.ClientID%>');
            if (comboEndo1Role == undefined || comboEndo1Role == null) return;
            var comboEndo1RoleVal = comboEndo1Role.get_selectedItem().get_value();
            if (comboEndo1RoleVal == null) return;
            var comboEndo2Role = $find('<%=Endo2RoleComboBox.ClientID%>');
            if (comboEndo1RoleVal == 2) {
                setComboVal(comboEndo2Role, 2);
            } else if (comboEndo1RoleVal == 3) {
                setComboVal(comboEndo2Role, 3);
            }
        }

        function getGMCCode(hiddenControl, userId) {
            $.ajax({
                type: "POST",
                url: webMethodLocation + "GetGMCCode",
                data: JSON.stringify({ userId: parseInt(userId) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d) {
                        $(hiddenControl).val(data.d);
                    }
                    else {
                        $(hiddenControl).val("");
                    }
                }
            });
        }

        function setEndoscopist2RoleChanged() {
            var comboEndo1Role = $find('<%=Endo1RoleComboBox.ClientID%>');
            var comboEndo2Role = $find('<%=Endo2RoleComboBox.ClientID%>');
            if (comboEndo2Role == undefined || comboEndo2Role == null) return;
            var comboEndo2RoleVal = comboEndo2Role.get_selectedItem().get_value();
            if (comboEndo2RoleVal == null) return;
            if (comboEndo2RoleVal == 2) {
                setComboVal(comboEndo1Role, 2);
            } else if (comboEndo2RoleVal == 3) {
                setComboVal(comboEndo1Role, 3);
            }
        }

        function setEndoscopist1() {
            var comboListConsultant = $find('<%=ListConsultantComboBox.ClientID%>');
            var comboListConsultantVal = comboListConsultant.get_selectedItem().get_value();
            var comboEndo1 = $find('<%=Endo1ComboBox.ClientID%>');
            var comboEndo1Val = comboEndo1.get_selectedItem().get_value();
            if (comboListConsultantVal != '' && comboEndo1Val == '') {
                setComboVal(comboEndo1, comboListConsultantVal);
            }
        }

        function setComboVal(combo, val) {
            var item = combo.findItemByValue(val);
            if (item != null) {
                item.select();
            }
        }

        function disableComboItems(comboEndoRole, disabledItems) {
            for (var i = 0; i < disabledItems; i++) {
                if (comboEndoRole.get_items().getItem(i).get_checked() == false) {
                    var vItem = comboEndoRole.get_items().getItem(i);
                    vItem.set_enabled(false);
                    vItem.get_element().style.color = "#c2d2e2";
                }
            }
        }

        function enableComboItems(comboEndoRole) {
            for (var i = 0; i < comboEndoRole.get_items().get_count(); i++) {
                if (comboEndoRole.get_items().getItem(i).get_checked() == false) {
                    var vItem = comboEndoRole.get_items().getItem(i);
                    vItem.set_enabled(true);
                    vItem.get_element().style.color = "#1e395b";
                }
            }
        }

        <%-- function CheckIfShow(sender, args) {
                var summaryElem = document.getElementById("<%=CreateProcValidationSummary.ClientID %>");

                //check if summary is visible
                if (summaryElem.style.display == "none") {
                    //API: if there are no errors, do not show the tooltip
                    args.set_cancel(true);
                }
            }--%>

        <%--  function CheckIfShowAddWard(sender, args) {
                var summaryElem = document.getElementById("<%=AddNewWardValidationSummary.ClientID %>");

                //check if summary is visible
                if (summaryElem.style.display == "none") {
                    //API: if there are no errors, do not show the tooltip
                    args.set_cancel(true);
                }
            }--%>

        function OnClientTabUnSelected(sender, args) {
            //accessing the last selected tab and giving the default styling
            args.get_tab().set_cssClass("unselected-tab-style");
        }

        function SelectPrintTab() {
            var tabStrip = $("#<%= PrevProcSummaryTabStrip.ClientID %>")[0];
            var tab = tabStrip.findTabByText("Print");
            if (tab) {
                tab.select();
                tab.set_cssClass("selected-tab-style");
            }
        }

        function OnClientHiding(sender, eventArgs) {
            window.location.replace(sender.get_value());
        }


        function TabStripLoad() {
            if (printChosen == true) {
                printChosen = false;
                return;
            }
        }

        function setDefaultView(sender, eventArgs) {
//            $('#<%=GPReportLinkButton.ClientID%>').addClass('selected-tab-button');
//            var tabStrip = $find("<%= PrevProcSummaryTabStrip.ClientID %>");
            //            var tab = tabStrip.findTabByText("GP Report");
            //            //accessing the gp report tab and setting css
            //            if (tab) {
            //                tab.select();
            //                tab.set_cssClass("selected-tab-style");
            //            }

        }

        function OnClientTabSelected(sender, args) {
                <%
'If ConfigureButton.Enabled Then
'    Session("HelpTooltipElementId") = ConfigureButton.ClientID
'    Session("HelpMessage") = "Click on Configure to setup Print Options."
'Else
'    Session("HelpTooltipElementId") = PrintButton.ClientID
'    Session("HelpMessage") = "Click on Print to open up the preview in a separate window."
'End If
            %>

            //            args.get_tab().set_cssClass("selected-tab-style");
//                <%--$("#<%= PrintPhotosCheckBox.ClientID%>").prop('checked', false);--%>
//            var tabStrip = $find("<%= PrevProcSummaryTabStrip.ClientID %>");
            //            var tabPhoto = tabStrip.findTabByText("Images");
//                <%--if (tabPhoto == null) { $("#<%= PrintPhotosCheckBox.ClientID%>").prop('disabled', true);  } else { $("#<%= PrintPhotosCheckBox.ClientID%>").prop('disabled', false); }--%>
            //            //accessing the selected tab and setting css
            //            args.get_tab().set_cssClass("selected-tab-style");
            //            FixPageViewHeight();

            //            if (args.get_tab().get_text() == "Images") {
            //                //disable the thumbnail slider buttons when there are not enough images
            //                var sliderRegionHeight = parseInt($(".rrClipRegion").height());
            //                var thumbnailImagesHeight = parseInt($(".rrItemsList").height());
            //                if (sliderRegionHeight > thumbnailImagesHeight) {
            //                    $("#BodyContentPlaceHolder_patientview_UpImage, #BodyContentPlaceHolder_patientview_DownImage").prop('disabled', true);
            //                }
            //                else {
            //                    $("#BodyContentPlaceHolder_patientview_UpImage, #BodyContentPlaceHolder_patientview_DownImage").prop('disabled', false);
            //                }
            //            }
        }



        function highlightListControl(elementRef) {
            newProcedureInitiated = true;
            //var inputElementArray = elementRef.getElementsByTagName('input');

            //for (var i = 0; i < inputElementArray.length; i++) {
            //    var inputElementRef = inputElementArray[i];
            //    var parentElement = inputElementRef.parentNode;

            //    if (parentElement) {
            //        if (inputElementRef.checked == true) {
            //            $(parentElement).addClass('rdChecked');
            //        }
            //        else {
            //            $(parentElement).removeClass('rdChecked');

            //        }
            //    }
            //}

        }

        var previousProcId;
        let procedureMenu;

        function DisableProcedureContextMenu(sender, eventArgs) {

            var node = eventArgs.get_node();
            var menu = eventArgs.get_menu();
            procedureMenu = menu
            let procedureId = node.get_attributes().getAttribute("ProcedureId")
            var nodeInnerText = node._element.innerText;
            let isParent = node.get_attributes().getAttribute("IsParent")
            menu.findItemByText("UnLock").hide();
            if ((nodeInnerText.indexOf('New Procedure') !== -1) || (nodeInnerText.indexOf('New Nursing Module') !== -1) || (nodeInnerText.indexOf('Procedure') !== -1) || (nodeInnerText.indexOf('Orders') !== -1)) {
                eventArgs.set_cancel(true);
            } else {
                if (node.get_attributes().getAttribute("ERS") == "False" || node.get_attributes().getAttribute("Locked") == "True" || node.get_attributes().getAttribute("isProcedureLocked") == 1) {
                    menu.findItemByText("Edit").disable();
                    menu.findItemByText("Procedure not carried out").disable();
                    menu.findItemByText("Post procedural data").disable();
                    menu.findItemByText("Breath Test").disable();
                }
                else {
                    menu.findItemByText("Edit").enable();
                    menu.findItemByText("Procedure not carried out").enable();
                    menu.findItemByText("Post procedural data").enable();
                    menu.findItemByText("Breath Test").enable();

                }
                //Enable/disable "Completed WHO surgical safety checklist?"
                var mnuWHOSurgical = menu.findItemByValue("who");
                if (mnuWHOSurgical) {
                    if (node.get_attributes().getAttribute("ERS") == "False") {
                        mnuWHOSurgical.disable();
                    }
                    else {
                        var srv = node.get_attributes().getAttribute("SurgicalSafetyCheckListCompleted");
                        if (srv == '' || srv == null) { mnuWHOSurgical.set_text('Completed WHO surgical safety checklist?'); }
                        else if (srv == 1) { mnuWHOSurgical.set_text('Completed WHO surgical safety checklist? (yes)'); }
                        else if (srv == 0) { mnuWHOSurgical.set_text('Completed WHO surgical safety checklist? (no)'); }

                        mnuWHOSurgical.enable();
                    }
                }

                if (node.get_attributes().getAttribute("Locked") == "True" || node.get_attributes().getAttribute("ERS") == "False" || node.get_attributes().getAttribute("CanDelete") == 0) {
                    menu.findItemByText("Delete").disable();
                }
                else {
                    menu.findItemByText("Delete").enable();
                }

                // added by Ferdowsi
                if (node.get_attributes().getAttribute("hasHistory") == 'true') {
                    menu.findItemByText("Edit by History").enable();

                }
                else {
                    menu.findItemByText("Edit by History").disable();
                }

                if (node.get_attributes().getAttribute("canPrint") == 0) {
                    menu.findItemByText("Print").disable();
                    menu.findItemByText("Print Preview").disable();
                }
                else {
                    menu.findItemByText("Print").enable();
                    menu.findItemByText("Print Preview").enable();
                }


                if (node.get_attributes().getAttribute("canPrintPreview") == 0) {
                    menu.findItemByText("Print Preview").hide();
                }

                if (node.get_attributes().getAttribute("ProcedureComplete") == "False") { // ||  == "True")) {
                    menu.findItemByText("Post procedural data").disable();
                    menu.findItemByText("Print").disable();
                    menu.findItemByText("Print Preview").disable();

                }
                if (node.get_attributes().getAttribute("PreviousProcedureId") > 0) {
                    previousProcId = node.get_attributes().getAttribute("PreviousProcedureId");
                    menu.findItemByText("Edit").disable();
                    menu.findItemByText("Delete").enable();
                    menu.findItemByText("Post procedural data").disable();
                    menu.findItemByText("Print").enable();
                    menu.findItemByText("Print Preview").disable();
                    menu.findItemByText("Media").disable();
                    menu.findItemByText("Procedure not carried out").disable();
                    menu.findItemByText("Breath Test").disable();
                }

                if (node.get_attributes().getAttribute("HasPhotos") == "False") {
                    menu.findItemByText("Media").hide();
                    menu.findItemByValue("ImagesSeparator").hide();
                }
                else {
                    menu.findItemByText("Media").show();
                    menu.findItemByValue("ImagesSeparator").show();
                }

                if ($('.procedureLocked_' + procedureId).hasClass('procedureLocked')) {
                    menu.findItemByText("Edit").disable();
                    if (node.get_attributes().getAttribute("Administrator") == "true") {
                        menu.findItemByText("UnLock").show();
                    }
                    else {
                        menu.findItemByText("UnLock").hide();
                    }
                }
                else {
                    menu.findItemByText("Edit").enable();
                }
                if (node.get_attributes().getAttribute("PreAssessmentId") > 0) {
                    menu.findItemByText("Add Procedure").show();
                    menu.findItemByText("Edit").enable();
                    if (isParent == "true") {
                        menu.findItemByText("Delete").enable();
                    }
                    else
                    {
                        menu.findItemByText("Delete").disable();
                    }
                    menu.findItemByText("Post procedural data").disable();
                    menu.findItemByText("Print").disable();
                    menu.findItemByText("Print Preview").disable();
                    menu.findItemByText("Media").disable();
                    menu.findItemByText("Procedure not carried out").disable();
                    menu.findItemByText("Breath Test").disable();

                }
                else {
                    menu.findItemByText("Add Procedure").hide();

                }
                if (node.get_attributes().getAttribute("NurseModuleId") > 0) {
                    menu.findItemByText("Add Procedure").hide();
                    menu.findItemByText("Delete").enable();
                    menu.findItemByText("Post procedural data").disable();
                    menu.findItemByText("Print").disable();
                    menu.findItemByText("Print Preview").disable();
                    menu.findItemByText("Media").disable();
                    menu.findItemByText("Procedure not carried out").disable();
                    menu.findItemByText("Breath Test").disable();

                }
                if (node.get_attributes().getAttribute("OrderCommsChild") == "True") {

                    menu.findItemByText("Order to Procedure").show();
                    menu.findItemByText("View OrderComms").show();

                    menu.findItemByText("Edit").disable();
                    menu.findItemByText("Delete").disable();
                    menu.findItemByText("Post procedural data").disable();
                    menu.findItemByText("Print").disable();
                    menu.findItemByText("Print Preview").disable();
                    menu.findItemByText("Media").disable();
                    menu.findItemByText("Procedure not carried out").disable();
                    menu.findItemByText("Breath Test").disable();
                }
                else {
                    menu.findItemByText("Order to Procedure").hide();
                    menu.findItemByText("View OrderComms").hide();
                }
            }
                <%If CBool(Session("isERSViewer")) Then%>
            menu.findItemByText("Edit").disable();
            menu.findItemByText("Delete").disable();
                <%End If%>

            // added by Ferdowsi TFS 4199
            if (node.get_attributes().getAttribute("canEdit") == 0) {
                menu.findItemByText("Edit").disable();
            }
            else {
                menu.findItemByText("Edit").enable()
            }

        }

        function unlockProcedure() {
            procedureId = lastNodeChosen.get_attributes().getAttribute("ProcedureId")

            $.ajax({
                type: "POST",
                url: "default.aspx/UnLockProcedure",
                data: JSON.stringify({ procedureId: procedureId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d == true) {
                        $find("<%=UnlockProcedureWindow.ClientID%>").close();
                     $('.procedureLocked_' + procedureId).removeClass('procedureLocked');
                     if (lastNodeChosen._attributes._data.ProcedureComplete == "False") {
                         $('.procedureLocked_' + procedureId).addClass("ProcedureIncomplete")
                     }
                 }
             },
             error: function (jqXHR, textStatus, data) {
                 alert(jqXHR.responseJSON.Message);
             }
         });
        }

        //Added by rony tfs-3059
        function deleteReportData() { 
              var obj = {};
              obj.procedureId = lastNodeChosen.get_attributes().getAttribute("ProcedureId")
              obj.previousProcedureId = lastNodeChosen.get_attributes().getAttribute("PreviousProcedureId");
              obj.sERSViewer = ('<%= Session("isERSViewer") %>' == '0' ? false : true);
              obj.deleteTxt = $('#<%=DeleteReportTextBox.ClientID%>').val();            
                // Check if the text box is empty
             if (obj.deleteTxt.trim() === "") {
                 $('#<%= DeleteReportTextBox.ClientID %>').css('border', '1px solid red');
                 logRequiredMessage("Please enter a reason");
                 $('#ValidationNotification', parent.document).show();
                 return false; 
             }
             else { $.ajax({
                    type: "POST",
                    url: "default.aspx/DeleteReportData",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data) {
                            $find("<%=DeleteReportDetailsWindow.ClientID%>").close();  
                            location.reload();
                        }
                      },
                      error: function (jqXHR, textStatus, data) {
                          alert(jqXHR.responseJSON.Message);
                      }
              });
              }
        }
        

        var printChosen;
        var selectedProcedureNode;
        var lastNodeChosen = "";      


        function OnClientContextMenuItemClicking(sender, eventArgs) {
            var IsNewPreAssess = $('#<%=IsNewPreAssess.ClientID%>').val();
            var IsNewNurses = $('#<%=IsNewNurses.ClientID%>').val();
            if (((isPreAssessChanges || isComorbidityChange) && IsNewPreAssess == "true") || (IsNewNurses == "true" && isNurseChanges)) {
                var proceed = confirm(confimationMessage);
                if (!proceed)
                    eventArgs.set_cancel(true);
                else {
                    isPreAssessChanges = false;
                    isComorbidityChange = false;
                    eventArgs.set_cancel(false);
                }
            }
            else if (isPreAssessChanges)
            {
                isPreAssessChanges = false;
            }
            var item = eventArgs.get_menuItem();
            var node = eventArgs.get_node();
            lastNodeChosen = node;
            if (item.get_text() == "Delete") {
                if (node.get_attributes().getAttribute("PreviousProcedureId") > 0) {

                    $('#<%=PreviousProcIdHiddenField.ClientID%>').val(node.get_attributes().getAttribute("PreviousProcedureId"));

                    $find('<%=DeleteProcedureRadWindow_ContentTemplate.ClientID%>').show();

                    eventArgs.set_cancel(true);

                    var procedureType = node._textElement.innerHTML.substring(13);

                    var procedureDate = node.get_attributes().getAttribute("ProcedureDate");
                    var formattedDate = procedureDate.substring(0, 10);

                    $('#<%=RemoveProcedureTypeLabel.ClientID%>').html('Delete Procedure: ');
                    $('#<%=RemoveProcedureTypeTextBox.ClientID%>').val(procedureType);

                    $('#<%=RemoveProcedureDateRadDatePicker.ClientID%>').val(formattedDate);

                    var removeReasonId = $find("<%= RemoveProcedureReasonRadTextBox.ClientID %>")
                    removeReasonId.set_value('');

                    sender.get_contextMenus()[0].hide();
                    return false;
                } else {
                    //Added by rony tfs-3059
                    var procedureId = node.get_attributes().getAttribute("ProcedureId");
        
                    if (procedureId > 0) {
                        var oWnd = $find("<%= DeleteReportDetailsWindow.ClientID %>");
                        if (oWnd != null) {
                            oWnd.set_title("Are you sure you want to delete this procedure and all the corresponding data?");
                            oWnd.show();
                        }
                        eventArgs.set_cancel(true);
                        sender.get_contextMenus()[0].hide();
                    }
                    else
                    {
                        
                        var prId = node.get_attributes().getAttribute("PreAssessmentId");
            
                        var msg = prId > 0 ? "Are you sure you want to delete this preassessment and all the corresponding data?" :
                            "Are you sure you want to delete this nurse module and all the corresponding data?";

                        if (!confirm(msg)) {
                            eventArgs.set_cancel(true);
                            sender.get_contextMenus()[0].hide();
                            sender.get_contextMenus()[0].hide();
                        }
                    }
                }
            }
            else if (item.get_text() == "Print") {
                printChosen = true;
                var node = eventArgs.get_node();
                sender.get_contextMenus()[0].hide();
            }
            else if (item.get_value() == "who") {
                var node = eventArgs.get_node();
                $("#<%=WhoCheckHidden.ClientID%>").val(node.get_attributes().getAttribute("ProcedureId"));
                var nStaty = node.get_attributes().getAttribute("SurgicalSafetyCheckListCompleted");
                if (nStaty == 1) {
                    $("#<%=rbSurgicalChecklistYes.ClientID%>").prop('checked', true);
                } else if (nStaty == 0) {
                    $("#<%=rbSurgicalChecklistNo.ClientID%>").prop('checked', true);
                }
                else {
                    $("#<%=rbSurgicalChecklistNo.ClientID%>").prop('checked', false);
                    $("#<%=rbSurgicalChecklistYes.ClientID%>").prop('checked', false);
                }


                var oWnd = $find("<%= SurgicalChecklistRadWindow.ClientID%>");
                oWnd.set_title("WHO surgical safety checklist - [ " + node.get_text() + " ]");
                eventArgs.set_cancel(true);
                sender.get_contextMenus()[0].hide();
                oWnd.show();
                //return false;
            }
            else if (item.get_value() == "Print") {
                SelectPrintTab();
                eventArgs.set_cancel(true);
            }


            else if (item.get_value() == "proc-not-carried-out") {
                selectedProcedureNode = eventArgs.get_node();   //## This is declared as Public.. for Later use!
                var selectedProcedureType = 'gastroscopy';      //## Default Value; unless something different is selected!
                var selectedProcedureName = selectedProcedureNode.get_text();

                if ((selectedProcedureName.indexOf("Upper") > 0) || (selectedProcedureName.indexOf("Proctoscopy") > 0))
                    selectedProcedureType = 'colon/sigmoidoscopy';     // Else- default is already set there!

                var selectedProcedureId = selectedProcedureNode.get_attributes().getAttribute("ProcedureId");
                //## Store these values for Updating the Table: ERS_Procedures or UGI-Episode!
                $("#selectedProcedureType").val(selectedProcedureType);
                $("#selectedProcedureId").val(selectedProcedureId);
                $("#selectedNodeText").val(selectedProcedureName);

                //'### Reset the Form... clear up the all previous selection and Error alerts!                                     
                //## Read if there is any Previous values for that Procedures!
                var selectedProcedureExistingDNA_Id = selectedProcedureNode.get_attributes().getAttribute("DNA_Reason");
                var selectedProcedureDNA_Text = selectedProcedureNode.get_attributes().getAttribute("DNA_Reason_PP_Text");

                //## Check whether any previous selection exist!
                if (selectedProcedureExistingDNA_Id == 0) {  //## Means no Existing record- prepare for New Record Entry!
                    $("#lblDNA_PP_Text").text('');  // Select a reason from the options above
                    $("#chkPatientDNA_Text").addClass('hidden');  //## Initially will stay Hidden.. after selecting one of the options from Radio grouip- make it visible!                        

                    //$("#chkPatientDNA_Text").attr('checked', 'unchecked');
                    $find("<%= btnProcNotcarriedOutSubmit.ClientID%>").set_enabled(false);  //## Disable the SAVE button- no selection is made- so save your arse!?
                    $("#chkPatientDNA_Text").prop('checked', false);
                    $('input:radio[name=ProcNotCarriedOut]').each(function () { $(this).prop('checked', false); });
                    //$("#ProcNotCarriedOut").prop('checked', false);
                } else {
                    $("#lblDNA_PP_Text").text(selectedProcedureDNA_Text);  // Select a reason from the options above
                    //$("#chkPatientDNA_Text").attr('checked', 'checked');
                    $("#chkPatientDNA_Text").prop('checked', true);
                    //$("#chkPatientDNA_Text").removeAttr('visibility', 'hidden');  //## Initially will stay Hidden.. after selecting one of the options from Radio grouip- make it visible!
                    $("#chkPatientDNA_Text").removeClass('hidden');  //## Initially will stay Hidden.. after selecting one of the options from Radio grouip- make it visible!

                    $find("<%= btnProcNotcarriedOutSubmit.ClientID%>").set_enabled(true);

                    selectedProcedureExistingDNA_Id = (selectedProcedureExistingDNA_Id * 1) - 1; //## Converting to INT then Minus one.. as Index is Zero based!
                    $("input:radio[name=ProcNotCarriedOut]:nth(" + selectedProcedureExistingDNA_Id + ")").attr('checked', true);
                }


                var oWnd = $find("<%= ProcNotCarriedOutRadWindow.ClientID%>");
                oWnd.set_title("Procedure NOT carried out - [ " + selectedProcedureName + " ]");
                eventArgs.set_cancel(true);
                sender.get_contextMenus()[0].hide();
                oWnd.show();

                //return false;
            }
            else if (item.get_text() == "Order to Procedure") {
                var loadingPanel = $("#<%= RadAjaxLoadingPanel1.ClientID %>");
                loadingPanel.show();

                var tree = $find("<%= PrevProcsTreeView.ClientID%>");
                var node = tree.findNodeByText("New Procedure");
                node.select();
            }
            // by Ferdowsi
            else if (item.get_text() == "Edit by History") {
                let procId = node.get_attributes().getAttribute("ProcedureId")
                var own = radopen("../UserControls/EditByHistory.aspx?procedureId=" + procId, " ", '500px', '300px');

                own.show()
                own.set_title("Edited by History")
                own.set_visibleStatusbar(false);

            }
        }

            <%--function ShowWard() {
                var radioButtonList = document.getElementsByName("<%=PatStatusRadioButtonList.ClientID%>");
                var listItems = radioButtonList.getElementsByTagName("input");
                for (var i = 0; i < listItems.length; i++) {
                    if (listItems[i].checked) {
                        alert("Selected value: " + listItems[i].value);
                    }
                }
                
                //var item = eventArgs.get_item();
                //var selectedText = sender.get_selectedItem().get_text();
                //ToggleWard(selectedText);
            }--%>



        function openPopUp() {
            $find("<%=UnlockProcedureWindow.ClientID%>").show();
        }
        function checkValidWard(sender, args) {
            document.getElementById("AddNewWardToolTipDiv").innerHTML = "";
            var validate = false;
            if ($find("<%= AddNewWardRadTextBox.ClientID%>").get_value() == null || $find("<%= AddNewWardRadTextBox.ClientID%>").get_value() == '') {
                validate = true; $('#AddNewWardDiv').show();
                addMessage("Ward is required", "AddNewWardToolTipDiv")
            } else { $('#AddNewWardDiv').hide(); }
            if (validate != true) { return; }
            else {
                args.set_cancel(true);
                $find("<%=AddNewWardErrorRadToolTip.ClientID%>").show();
            }
        }
        function logMessage(msgi) {
            var msger = document.getElementById("createValDiv").innerHTML;
            if (msger == null || msger == '') {
                document.getElementById("createValDiv").innerHTML = msgi;
            } else {
                document.getElementById("createValDiv").innerHTML = msger + "<br/> " + msgi;
            }
        }
        function logRequiredMessage(msgi) {
            var msger = document.getElementById("masterValDiv").innerHTML;
            if (msger == null || msger == '') {
                document.getElementById("masterValDiv").innerHTML = msgi;
            } else {
                document.getElementById("masterValDiv").innerHTML = msger + "<br/> " + msgi;
            }
        }

        function addMessage(msgi, ctrl) {
            var msger = document.getElementById(ctrl).innerHTML;
            if (msger == null || msger == '') {
                document.getElementById(ctrl).innerHTML = msgi;
            } else {
                document.getElementById(ctrl).innerHTML = msger + "<br/> " + msgi;
            }
        }

        var lightBox;
        function lightBoxLoad(sender, args) {
            lightBox = sender;
        }

        function showLightBox(index) {
            //alert(index);
            lightBox.set_currentItemIndex(index);
            lightBox.show();
        }

        function lightBoxShowed(sender, args) {
            args.set_cancel(true);
        }

        function onImageGalleryCreated(sender, args) {
            //adjust the height of the thumbnail area based on the number of image rows and the height of the image
            //alert(sender.get_thumbnailsArea().get_element().style.height);
            //alert(sender.get_items().length);
            //$(".rigThumbnailsList").height(h);
            //sender.get_thumbnailsArea().get_element().style.height = sender.get_element().clientHeight - parseInt(sender.get_thumbnailsArea().get_element().style.height, 10) + "px";
        }

        //function openImageWindow() {
        //    var oWnd = $find(" ImageWindow.ClientID");
        //    oWnd.show();
        //    return false;
        //}

        function AddLightBoxItem() {
        <%--var lightBox = $find('<%= RadLightBox1.ClientID %>');
        var lightBoxItem = new Telerik.Web.UI.LightBoxItem;
        lightBoxItem.set_imageUrl("http://localhost:54288/Photos/1_1_UNI00041.bmp");
        //lightBoxItem.set_description("Description of the second item");
        //lightBoxItem.set_title("Title of the second item");
        var lightBoxItemCollection = lightBox.get_items();
        lightBoxItemCollection.clear();
        lightBoxItemCollection.add(lightBoxItem);
        lightBox.show();--%>

            //var cb = lightbox.get_element().getElementsByClassName("checkstate");


            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest("ChangeMediaSource," + "path");

        }

        <%--function OpenLightBox()
    {
        var lightBox = $find('<%= RadLightBox2.ClientID %>');
        lightBox.show();
    }--%>

        function ThumnailClicked(sender, args) {
            var currentItem = args.get_item().get_element().firstChild;
            //Clear the css for all the items other than the selected item
            $(sender.get_items()).each(function () {
                var myItem = this.get_element().firstChild;
                if (myItem == currentItem) {
                    myItem.className = "cssSelectedItem";
                    //myItem.parentElement.style.marginLeft = "2px"; //5-3
                    //myItem.parentElement.style.marginTop = "-3px"; //0-3
                    myItem.parentElement.style.margin = "1px";
                }
                else {
                    myItem.className = "";
                    //myItem.parentElement.style.marginLeft = "5px"; //take the values back to the ones defined in the css rrItem class
                    //myItem.parentElement.style.marginTop = "0px";
                    myItem.parentElement.style.margin = "4px";
                }
            });
        }
       function setNewProcedureTab() {

          if (confirm('Are you sure you want to discard your changes?')) {
                //alert('Came here');
                var tree = $find("<%= PrevProcsTreeView.ClientID%>");
                var node = tree.get_selectedNode();
                node.select();
            }

        }
        function pathologyResultsTabClose() {
            //var tabStrip = $find("<%= PrevProcSummaryTabStrip.ClientID %>");
            //var tab = tabStrip.findTabByText("Pathology Results");
            ////accessing the gp report tab and setting css
            //if (tab) {
            //    tab.hide();
            //}
            //setDefaultView();
            var tree = $find("<%= PrevProcsTreeView.ClientID%>");

            //alert(tree);

            var node = tree.get_selectedNode();
            node.select();
        }

        function ddlComparisonValidation(sender) {
            if (sender == "endo") {
                var endo1 = $find('<%=Endo1ComboBox.ClientID%>').get_value();
                var endo2 = $find('<%=Endo2ComboBox.ClientID%>').get_value();
                if (endo1 == endo2) {
                    alert("Endoscopist 1 and Endoscopist 2 must not match.");
                    $find('<%=Endo1ComboBox.ClientID%>').clearSelection();

                }
            }
        }
        function validateGMCCodes(sender, args) {
            if (validatePage(sender, args)) {
                newProcedureInitiated = false;
                var listConsultant = $find('<%=ListConsultantComboBox.ClientID%>').get_value();
                var endo1 = $find('<%=Endo1ComboBox.ClientID%>').get_value();
                var endo2 = $find('<%=Endo2ComboBox.ClientID%>').get_value();

                var listConsultantGMC = $('#<%=ListConsultantGMCHiddenField.ClientID%>').val();
                var endo1GMC = $('#<%=Endo1GMCHiddenField.ClientID%>').val();
                var endo2GMC = $('#<%=Endo2GMCHiddenField.ClientID%>').val();

                if (listConsultantGMC == "" || endo1GMC == "" || (endo2 != "" && endo2GMC == "")) {
                    var obj = {};
                    var endoIDs = [];
                    endoIDs.push(parseInt(listConsultant));
                    endoIDs.push(parseInt(endo1));
                    if (endo2 != "") {
                        endoIDs.push(parseInt(endo2));
                    }

                    obj.endoIds = endoIDs;

                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "CheckGMCCodes",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            if (data.d != "") {
                                var url = "Common/UpdateGMCCodes.aspx?IDs=" + data.d.join();

                                var oWnd = $find("<%= GMCCodeRadWindow.ClientID %>");
                                oWnd._navigateUrl = url;
                                oWnd.show();
                            }
                        }
                    });
                    args.set_cancel(true);
                }
                else if (listConsultantGMC != "" || endo1GMC != "" || (endo2 != "" && endo2GMC != "")) {
                    var obj = {};
                    var endoIDs = [];
                    var gmcIDs = [];
                    endoIDs.push(parseInt(listConsultant));
                    gmcIDs.push(parseInt(listConsultantGMC));
                    endoIDs.push(parseInt(endo1));
                    gmcIDs.push(parseInt(endo1GMC));
                    if (endo2 != "" && endo2GMC != "") {
                        endoIDs.push(parseInt(endo2));
                        gmcIDs.push(parseInt(endo2GMC));
                    }

                    obj.endoIds = endoIDs;
                    obj.gmcIDs = gmcIDs;
                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "ValidateGMCCodes",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: false,
                        success: function (data) {
                            if (data.d != "") {
                                var url = "Common/UpdateGMCCodes.aspx?IDs=" + data.d.join();

                                var oWnd = $find("<%= GMCCodeRadWindow.ClientID %>");
                                oWnd._navigateUrl = url;
                                oWnd.show();
                                args.set_cancel(true);
                            } else {
                                args.set_cancel(false);
                            }
                        }
                    });
                }
            }
        }
        function onClickingNode(sender, eventArgs)
        {
            var node = eventArgs.get_node();
            var id = node.get_attributes().getAttribute("PreAssessmentId");
            var preAssessBtnDiv = document.getElementById('<%= preAssessBtnDiv.ClientID %>');
            var IsNewPreAssess = $('#<%=IsNewPreAssess.ClientID%>').val();
            var IsNewNurses = $('#<%=IsNewNurses.ClientID%>').val();

            if (((isPreAssessChanges || isComorbidityChange) && IsNewPreAssess == "true") || (isNurseChanges && IsNewNurses == "true")) {
                var proceed = confirm(confimationMessage);
                if (!proceed)
                    eventArgs.set_cancel(true);
                else {
                    isPreAssessChanges = false;
                    isComorbidityChange = false;
                    isNurseChanges = false;
                    eventArgs.set_cancel(false);
                }
            }
            else
            {
                isNurseChanges = false;
                isPreAssessChanges = false;
                isComorbidityChange = false;
                eventArgs.set_cancel(false);
            }
        }
          //function onNodeClicked(sender, eventArgs) 
          //{


          //  }

        function validateQuestions(sender, args)
        {

            var preAssessmentId = $('#<%=PreAssessmentHiddenField.ClientID%>').val();
            $.ajax({
                type: "POST",
                url: "Default.aspx/CheckRequiredQuestion",
                data: JSON.stringify({ preAssessmentId: preAssessmentId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var questions = response.d;

                    if (questions)
                    {
                        isPreAssessChanges = false;
                        args.set_cancel(true);
                        logRequiredMessage(questions);
                        $('#ValidationNotification', parent.document).show();
                        addRedBorderForRequiredField(questions);
                    }
                    else
                    {
                        $find("<%=CreatePreAssessmentProcedureButton1.ClientID %>").click();

                    }
                }
            });
        }
        
        function validateNurseQuestions(sender, args) {

            var nurseModuleId = $('#<%=NurseModuleHiddenField.ClientID%>').val();

                    $.ajax({
                        type: "POST",
                        url: "Default.aspx/CheckNurseModuleRequiredQuestions",
                        data: JSON.stringify({ nurseModuleId: nurseModuleId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var questions = response.d;

                            if (questions) {
                                isNurseChanges = false;
                                args.set_cancel(true);
                                logRequiredMessage(questions);
                                $('#ValidationNotification', parent.document).show();
                                addRedBorderForNurseRequiredField(questions);
                            }
                            else {
                                $find("<%=CreateNurseModuleProcedureButton1.ClientID %>").click();

                    }
                }
            });
                }
        function addRedBorderForRequiredField(questions)
        {
            var IsNewNurses = $('#<%=IsNewNurses.ClientID%>').val();

            if (IsNewNurses == true)
            {
                $("#preAssessmentTableId tr").each(function () {

                    var isMandatoryVisible = $(this).find('img[alt="Mandatory Field"]').is(":visible");

                    if (isMandatoryVisible) {

                        var $radioButtons = $(this).find('input[type="radio"]');

                        if ($radioButtons.length > 0) {

                            var isSelected = $radioButtons.is(':checked');
                            if (!isSelected) {
                                $radioButtons.each(function () {
                                    $(this).next('label').css('color', 'red');
                                });
                            }
                            else {
                                $radioButtons.each(function () {
                                    $(this).next('label').css('color', 'black');
                                });
                            }
                        }

                        var $freeTextInputs = $(this).find('input[type="text"].assessment-question-input');

                        if ($freeTextInputs.length > 0) {
                            if ($freeTextInputs.val().trim() === '') {
                                $freeTextInputs.css('border', '1px solid red');
                            }
                        }
                        var comboBox = $(this).find('.assessment-dropdown-combobox');
                        if (comboBox.length) {


                            var comboBoxs = $find(comboBox.attr('id'));

                            if (comboBoxs.get_selectedIndex() === 0) {

                                comboBox.css('border', '1px solid red');
                            } else {

                                comboBox.css('border', '');
                            }
                        }
                    }
                });
            }
        }

        function addRedBorderForNurseRequiredField(questions) {
            $("#nurseModuleTableId tr").each(function () {

                var isMandatoryVisible = $(this).find('img[alt="Mandatory Field"]').is(":visible");

                if (isMandatoryVisible) {

                    var $radioButtons = $(this).find('input[type="radio"]');

                    if ($radioButtons.length > 0) {

                        var isSelected = $radioButtons.is(':checked');
                        if (!isSelected) {
                            $radioButtons.each(function () {
                                $(this).next('label').css('color', 'red');
                            });
                        }
                        else {
                            $radioButtons.each(function () {
                                $(this).next('label').css('color', 'black');
                            });
                        }
                    }

                    var $freeTextInputs = $(this).find('input[type="text"].nurse-module-question-input');

                    if ($freeTextInputs.length > 0) {
                        if ($freeTextInputs.val().trim() === '') {
                            $freeTextInputs.css('border', '1px solid red');
                        }
                    }
                    var comboBox = $(this).find('.nurse-module-dropdown-combobox');
                    if (comboBox.length) {


                        var comboBoxs = $find(comboBox.attr('id'));

                        if (comboBoxs.get_selectedIndex() === 0) {

                            comboBox.css('border', '1px solid red');
                        } else {

                            comboBox.css('border', '');
                        }
                    }
                }
            });

        }
        function triggerOriginalEvent(args) {
            var preAssessmentId = $('#<%=PreAssessmentHiddenField.ClientID%>').val();
            $.ajax({
                type: "POST",
                url: "Default.aspx/CheckRequiredQuestion",
                data: JSON.stringify({ preAssessmentId: preAssessmentId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response)
                {
                    var questions = response.d;

                    if (questions)
                    {
                        args.set_cancel(true);
                        return true;


                    }
                    else
                    {
                        return false;
                    }
                }
                });

        }

        function AddNewConsultantPopUp(sender) {
            cbo = sender;
            if ($(cbo).val() === "Add new") {
                var own = radopen("../Products/Options/EditConsultants.aspx?newprocedure=true", "Add consultant", 650, 550);
                own.set_visibleStatusbar(false);
                return false;
            }
        }

        function refreshGrid(args) {
            $find("<%= RadAjaxManager.GetCurrent(Page).ClientID %>").ajaxRequest("NewConsultant|" + args);
        }

        function updateGMC(arg) {
            //set with any values as this function wouldn't have been reached if GMC codes weren't updated
            var listConsultantGMC = $('#<%=ListConsultantGMCHiddenField.ClientID%>').val("updated");
            var endo1GMC = $('#<%=Endo1GMCHiddenField.ClientID%>').val("updated");
            var endo2GMC = $('#<%=Endo2GMCHiddenField.ClientID%>').val("updated");
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function tabButtonSelected(ctrl) {
            $('.selected-tab-button').each(function () {
                $(this).removeClass('selected-tab-button');
            });

            $(ctrl).addClass('selected-tab-button');

            var tabStrip = $find("<%= PrevProcSummaryTabStrip.ClientID %>");
            var tab;


            var pageToShow = $(ctrl).data("page");
            if (pageToShow == "gpReport") {
                tab = tabStrip.findTabByText("Report");
            }
            else if (pageToShow == "print") {
                tab = tabStrip.findTabByText("Print");
            }
            else if (pageToShow == "media") {
                tab = tabStrip.findTabByText("Media");
            }
            else if (pageToShow == "pathResults") {
                tab = tabStrip.findTabByText("Pathology Results");
            }
            else if (pageToShow == "uploadPDF") {
                tab = tabStrip.findTabByText("Upload PDF");
            }
            else if (pageToShow == "deletePDF") {
                tab = tabStrip.findTabByText("Delete PDF");
            }

            if (tab) {
                tab.select();
                tab.set_cssClass("selected-tab-style");
            }

            return false;
        }

        function ConsultantChanged(sender, args) {
            var slyCombo = $find("<%= SpecialityRadComboBox.ClientID %>");
            var sly = args.get_dataItem() === undefined ? null : args.get_dataItem().GroupName;
            if (sly == null || sly == 'null' || sly == '') {
                slyCombo.findItemByText('').select();
            } else {
                var chkSlyVal = slyCombo.findItemByText(sly);
                if (chkSlyVal == null || chkSlyVal == 'null') {
                    slyCombo.findItemByText('').select();
                } else {
                    chkSlyVal.select();
                }
            }


            var hplCombo = $find("<%= HospitalComboBox.ClientID %>");
            var hplcnt = hplCombo.get_items().get_count();
            var hpl = args.get_dataItem() === undefined ? null : args.get_dataItem().Hospital;
            if (hpl == '(All hospitals)' && hplcnt == 2) {
                hplCombo.trackChanges();
                hplCombo.get_items().getItem(1).select();
                hplCombo.commitChanges();
            } else if (hpl == null || hpl == 'null' || hpl == '' || hpl == '(All hospitals)' || hpl == '(Unspecified)' || hpl == '(Multiple hospitals)') {
                hplCombo.findItemByText('').select();
            } else {
                var chkHospVal = hplCombo.findItemByText(hpl);
                if (chkHospVal == null || chkHospVal == 'null') {
                    hplCombo.findItemByText('').select();
                } else {
                    chkHospVal.select();
                }
            }
        }

        <%--function removePDFFile() {
            //debugger;            
            var node = lastNodeChosen;          

            //var previousProcId = node.get_attributes().getAttribute("PreviousProcedureID")
            var removeReasonId = $find("<%= RemoveProcedureReasonRadTextBox.ClientID %>")
            var removeReason = removeReasonId.get_value();
                        
            var obj = {};

            obj.previousProcId = previousProcId;
            obj.removeReason = removeReason;            

            $.ajax({
                type: "POST", 
                url: "Default.aspx/RemovePDFFile",
                data: JSON.stringify(obj),                
                contentType: "application/json; charset=utf-8",
                dataType: "json",            
                success: function (data) {
                    if (data.d != null) {                        
                        //alert("success!");   
                        location.reload();
                    }
                    else {
                        alert("no data!");
                    }
                },
                error: function (jqXHR, textStatus, data) {                            
                    alert("error!");
                }
            });
            //args.set_cancel(true);
        } --%>

        function modalPosition() {
            var width = $('.modal').width();
            var pageWidth = $(window).width();
            var x = (pageWidth / 2) - (width / 2);
            $('.modal').css({ left: x + 'px' });
        }

        //<![CDATA[
        Sys.Application.add_load(function () {
            $windowContentDemo.contentTemplateID = "<%=RadWindow_ContentTemplate.ClientID%>";
            $windowContentDemo.templateWindowID = "<%=RadWindow_ContentTemplate.ClientID %>";
            <%--$windowContentDemo.urlWindowID = "<%=RadWindow_NavigateUrl.ClientID %>";--%>
            <%--$windowContentDemo.label = "<%=Label1.ClientID %>";--%>
            <%--$windowContentDemo.textBox = "<%= Textbox1.ClientID %>";--%>
        });

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow) oWindow = window.radWindow;
            else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
            return oWindow;
        }

        function Close(evt) {
            //debugger;
            //evt.preventDefault();
            if (confirm('Are you sure you want to discard your changes?'))
                GetRadWindow().close();
        }

        function CloseWindowDelete() {
            var oManager = GetRadWindowManager();
            //Call GetActiveWindow to get the active window 
            var oActive = oManager.getActiveWindow();

            if (oActive == null) { window.parent.CloseWindow(); } else { oActive.close(null); return false; }
            // return false;
        }

        function CloseWindowUpdate() {
            var oManager = GetRadWindowManager();
            //Call GetActiveWindow to get the active window 
            var oActive = oManager.getActiveWindow();

            var dateTimePicker = $find('<%=ProcedureDateRadDatePicker.ClientID%>');
            dateTimePicker.clear();
            $('#<%=ProcedureDescriptionTextBox.ClientID%>').val('');
            //$('#FileUpload1').val('');
            var fileUpload = $("[id*=FileUpload1]");

            var newFileUpload = $("<input type = 'file' />");

            //Append it next to the original FileUpload.
            fileUpload.after(newFileUpload);

            //Remove the original FileUpload.
            fileUpload.remove();

            //Set the Id and Name to the new FileUpload.
            newFileUpload.attr("id", id);
            newFileUpload.attr("name", name);

            if (oActive == null) { window.parent.CloseWindow(); } else { oActive.close(null); return false; }
            // return false;
        }


        function nurse1Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                newProcedureInitiated = true;
                var b = $find('<%=Nurse2ComboBox.ClientID %>');
                var c = $find('<%=Nurse3ComboBox.ClientID %>');
                var d = $find('<%=Nurse4ComboBox.ClientID %>');
                var nurse2 = b.get_text();
                var nurse3 = c.get_text();
                var nurse4 = d.get_text();
                if (nurse2 == select) {
                    b.set_text("");
                }
                if (nurse3 == select) {
                    c.set_text("");
                }
                if (nurse4 == select) {
                    d.set_text("");
                }
            }
        }

        function ProcTypeRadComboBoxChanged(sender, args) {
            newProcedureInitiated = true;
            setProcedurePoints(sender.get_value());
        }

        function nurse2Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                newProcedureInitiated = true;
                var b = $find('<%=Nurse1ComboBox.ClientID %>');
                var c = $find('<%=Nurse3ComboBox.ClientID %>');
                var d = $find('<%=Nurse4ComboBox.ClientID %>');
                var nurse1 = b.get_text();
                var nurse3 = c.get_text();
                var nurse4 = d.get_text();
                if (nurse1 == select) {
                    b.set_text("");
                }
                if (nurse3 == select) {
                    c.set_text("");
                }
                if (nurse4 == select) {
                    d.set_text("");
                }
            }

        }
        function nurse3Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                newProcedureInitiated = true;
                var b = $find('<%=Nurse1ComboBox.ClientID %>');
                var c = $find('<%=Nurse2ComboBox.ClientID %>');
                var d = $find('<%=Nurse4ComboBox.ClientID %>');
                var nurse1 = b.get_text();
                var nurse2 = c.get_text();
                var nurse4 = d.get_text();
                if (nurse1 == select) {
                    b.set_text("");
                }
                if (nurse2 == select) {
                    c.set_text("");
                }
                if (nurse4 == select) {
                    d.set_text("");
                }
            }
        }



        function nurse4Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                newProcedureInitiated = true;
                var b = $find('<%=Nurse1ComboBox.ClientID %>');
                var c = $find('<%=Nurse2ComboBox.ClientID %>');
                var d = $find('<%=Nurse3ComboBox.ClientID %>');
                var nurse1 = b.get_text();
                var nurse2 = c.get_text();
                var nurse3 = d.get_text();
                if (nurse1 == select) {
                    b.set_text("");
                }
                if (nurse2 == select) {
                    c.set_text("");
                }
                if (nurse3 == select) {
                    d.set_text("");
                }
            }
        }







        /*  function ProcTypeRadComboBoxChanged(sender, args) {
              setProcedurePoints(sender.get_value());
          }*/
        // Added by rony tfs-4175
        function setProcedurePoints(procedureTypeId) {
            var obj = {};
            obj.procedureTypeId = parseInt(procedureTypeId);

            obj.operatingHospitalId = parseInt(<%= Session("OperatingHospitalID") %>);
            obj.listTypeId = $('#<%=ListTypeComboBox.ClientID%>').val();


            var productSelected = $('#<%=ProductRadioButtonList.ClientID%> input:checked').val();
            if (productSelected == 3) {
                $(".ProcedurePointsTDCSS").hide();
            }
            else {
                $(".ProcedurePointsTDCSS").show();
            }


            $.ajax({
                type: "POST",
                url: "default.aspx/GetGenderSpecific",
                data: JSON.stringify(obj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d == true) {
                        $(".ImageGenderTR").show();
                        setRequiredField('<%=ImageGenderID.ClientID%>', 'Choose Image Type');
                    }
                    else {
                        $(".ImageGenderTR").hide();
                        removeRequiredField('<%=ImageGenderID.ClientID%>', 'Choose Image Type');
                    }
                },
                error: function (jqXHR, textStatus, data) {
                    alert(jqXHR.responseJSON.Message);
                }
            });





            $.ajax({
                type: "POST",
                url: "default.aspx/getProcedurePoints",
                data: JSON.stringify(obj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d != null) {
                        $find('<%=ProcedurePointsRadNumericTextBox.ClientID%>').set_value(data.d);
                    }
                    else {
                        $find('<%=ProcedurePointsRadNumericTextBox.ClientID%>').set_value(1);
                    }
                },
                error: function (jqXHR, textStatus, data) {
                    alert(jqXHR.responseJSON.Message);
                }
            });
        }


        function ReferrerTypeComboBoxChanged(sender, args) {
            newProcedureInitiated = true;
            //debugger;
            $find('<%=GPReferralTextBox.ClientID%>').set_value('');
            $find('<%=OtherReferrerTypeTextBox.ClientID%>').set_value('');

            if (sender.get_selectedItem().get_text().toLowerCase() == "gp" || sender.get_selectedItem().get_text().toLowerCase() == "") {

                $('.other-type-input').hide();
                //alert(sender.get_selectedItem().get_text().toLowerCase());


                //remove other referreral type as a required field
                removeRequiredField('<%=OtherReferrerTypeTextBox.ClientID%>', 'other referrer type');

                //remove referring consulant controls as required fields
                removeRequiredField('<%=ConsultantComboBox.ClientID%>', 'consultant');
                removeRequiredField('<%=SpecialityRadComboBox.ClientID%>', 'speciality');
                removeRequiredField('<%=HospitalComboBox.ClientID%>', 'hospital');

                //make referreral type a required field
                setRequiredField('<%=ReferrerTypeComboBox.ClientID%>', 'referrer type');
                $('.referral-consultant-row').hide();
                if (sender.get_selectedItem().get_text().toLowerCase() == "gp") $('.gp-referral-text-input').show();
                else {
                    $('.gp-referral-text-input').hide();
                }
            }
            else {
                if (sender.get_selectedItem().get_text().toLowerCase() == 'other') {
                    $('.other-type-input').show();
                    setRequiredField('<%=OtherReferrerTypeTextBox.ClientID%>', 'other referrer type');

                    //remove referring consulant controls as required fields
                    removeRequiredField('<%=ConsultantComboBox.ClientID%>', 'consultant');
                    removeRequiredField('<%=SpecialityRadComboBox.ClientID%>', 'speciality');
                    removeRequiredField('<%=HospitalComboBox.ClientID%>', 'hospital');
                    $('.referral-consultant-row').hide();
                }
                else { //other trust, bscp
                    $('.referral-consultant-row').show();
                    setRequiredField('<%=ConsultantComboBox.ClientID%>', 'consultant');
                    setRequiredField('<%=SpecialityRadComboBox.ClientID%>', 'speciality');
                    setRequiredField('<%=HospitalComboBox.ClientID%>', 'hospital');


                    $('.other-type-input').hide();
                    removeRequiredField('<%=OtherReferrerTypeTextBox.ClientID%>', 'other referrer type');
                }
                $('.gp-referral-text-input').hide();
            }
        }

        function ProviderTypeComboBoxChanged(sender, args) {
            newProcedureInitiated = true;
            if (sender.get_selectedItem().get_text().toLowerCase().indexOf("other") > -1) {
                $('.other-provider-input').show();
                setRequiredField('<%=OtherProviderRadTextBox.ClientID%>', 'other provider type');
            }
            else { //other trust, bscp
                $('.other-provider-input').hide();
                removeRequiredField('<%=OtherProviderRadTextBox.ClientID%>', 'other provider type');
            }
        }

        function OnClientSelectedIndexChanged() {
            newProcedureInitiated = true;
        };
    </script>
</telerik:RadCodeBlock>