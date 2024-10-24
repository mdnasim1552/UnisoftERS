<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PathologyResults.ascx.vb" Inherits="UnisoftERS.PathologyResults" %>
<style>
    .original-text {
        width: 645px !important;
    }
</style>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="false"
    Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="PreviewWindow" runat="server" Title="Print report" OnClientClose="OnClientClosePreviewHandler"
            Width="850px" Height="900px" ReloadOnShow="true" ShowContentDuringLoad="false"
            Modal="true" VisibleStatusbar="true" Skin="Metro" OnClientShow="showContentForIE" Behaviors="Close">
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>

<telerik:RadFormDecorator ID="PathResultsRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="PathResultsContent" Skin="Metro" />
<div id="PathResultsContent">
    <div id="PathologyResultsDiv" runat="server" style="height: 750px;">
        <table style="width: 70%; margin-bottom: 20px; margin-left: 20px;">
            <tr>
                <td>Date of specimen:<br />
                    <telerik:RadDatePicker ID="DateofSpecimenRadDatePicker" Style="z-index: 9999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                </td>
                <td>Lab report number:<br />
                    <telerik:RadTextBox ID="LabReportNumberRadTextBox" runat="server" Width="73" />
                </td>
                <td>Date of path report:<br />
                    <telerik:RadDatePicker ID="DateOfPathReportRadDatePicker" Style="z-index: 9999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />

                </td>
                <td>Date path report received:<br />
                    <telerik:RadDatePicker ID="DateReportReceivedRadDatePicker" Style="z-index: 9999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                </td>
                <td>
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <td style="padding-left: 21px; vertical-align: top;">
                    <asp:CheckBox ID="AdenomaConfirmedCheckbox" runat="server" Text="Adenoma confirmed histologically" />&nbsp;
                    <asp:CheckBox ID="AdequateFNACheckBox" runat="server" Text="Adequate FNA" />
                </td>
            </tr>
            <tr>
                <td>
                    <div style="margin-left: 20px;">
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage2" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Default"
                            Orientation="HorizontalTop">
                            <Tabs>
                                <telerik:RadTab Text="Pathology Report" Font-Bold="true" Value="0" />
                                <telerik:RadTab Text="Further Procedure(s)" Font-Bold="true" Value="1" />
                                <telerik:RadTab Text="Follow Up" Font-Bold="true" Value="2" />
                                <telerik:RadTab Text="Advice / Comments" Font-Bold="true" Value="3" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage2" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="RadPageViewPathReportText" runat="server">
                                <div id="PathReportTextTab" class="multiPageDivTab" style="z-index: 9999;">
                                    <fieldset>
                                        <legend>Pathology Report Text</legend>
                                        <telerik:RadTextBox ID="PathologyReportTextRadTextBox" runat="server" TextMode="MultiLine" Width="645" Height="120" />

                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView0" runat="server">
                                <div id="multiPageDivTab" class="multiPageDivTab" style="z-index: 9999;">
                                    <fieldset>
                                        <legend>New Text</legend>

                                        <table class="rptSummaryText10 path-results-tab-table" cellpadding="3" cellspacing="3">
                                            <tr>
                                                <td>
                                                    <telerik:RadComboBox ID="FurtherProcedureComboBox" runat="server" Skin="Metro" Width="200"
                                                        Style="margin-right: 5px; z-index: 9999;" />
                                                    in
                                                &nbsp;&nbsp;
                                                <telerik:RadNumericTextBox ID="FurtherProcedureDueCountNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                    <telerik:RadComboBox ID="FurtherProcedureDueTypeComboBox" runat="server" Skin="Metro" Width="70"
                                                        Style="margin-right: 5px; z-index: 9999;" />
                                                    <telerik:RadButton ID="FurtherProcedureBuildTextButton" runat="server" Text="Add" Skin="Metro"
                                                        AutoPostBack="false" OnClientClicked="BuildFurtherProcText" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>(Max 255 characters)<br />
                                                    <telerik:RadTextBox ID="FurtherProcedureTextBox" runat="server" Skin="Metro" TextMode="MultiLine"
                                                        Width="600" Height="80" /><img src="../Images/phrase_library.png" style="padding-left: 5px" onclick="javascript:showPathLibrary('PathFurtherProc');return false;" title="Phrases" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                    <fieldset style="visibility:hidden;">
                                        <legend>Original Text</legend>
                                        <telerik:RadTextBox ID="FurtherProcedureOriginalTextRadTextBox" runat="server" TextMode="MultiLine" Enabled="false" CssClass="original-text" Visible="false" Height="120" />
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="multiPageDivTab1" class="multiPageDivTab" style="z-index: 9999;">
                                    <fieldset>
                                        <legend>New text</legend>
                                        <table class="rptSummaryText10 path-results-tab-table" cellpadding="3" cellspacing="3">
                                            <tr>
                                                <td style="width: 125px;">Return to the
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="ReturnToComboBox" runat="server" Skin="Metro" Width="200" Style="z-index: 9999;" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>No further follow up
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="NoFurtherFollowUpCheckBox" runat="server" Text="" Style="margin-left: -2px; z-index: 9999;"
                                                        onchange="ToggleReviewDetails('ReviewTR');" />
                                                </td>
                                            </tr>
                                            <tr id="ReviewTR" runat="server">
                                                <td>Review will be in the
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="ReviewLocationComboBox" runat="server" Skin="Metro" Width="130" Style="z-index: 9999;" />
                                                    &nbsp;
                                                                                            in
                                                                                            &nbsp;
                                                                                            <telerik:RadNumericTextBox ID="ReviewDueCountNumericTextBox" runat="server"
                                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                                IncrementSettings-Step="1"
                                                                                                Width="35px"
                                                                                                MinValue="0">
                                                                                                <NumberFormat DecimalDigits="0" />
                                                                                            </telerik:RadNumericTextBox>
                                                    <telerik:RadComboBox ID="ReviewDueTypeComboBox" runat="server" Skin="Metro" Width="70"
                                                        Style="margin-right: 5px; z-index: 9999;" />
                                                    <telerik:RadButton ID="ReviewBuildTextButton" runat="server" Text="Add" Skin="Metro"
                                                        AutoPostBack="false" OnClientClicked="BuildFollowUpText" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">(Max 255 characters)<br />
                                                    <telerik:RadTextBox ID="ReviewTextBox" runat="server" Skin="Metro" TextMode="MultiLine"
                                                        Width="600" Height="80" /><img src="../Images/phrase_library.png" style="padding-left: 5px" onclick="javascript:showPathLibrary('PathFollowUp');return false;" title="Phrases" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                    <fieldset style="visibility:hidden;">
                                        <legend>Original Text</legend>
                                        <telerik:RadTextBox ID="FollowUpOriginalTextRadTextBox" runat="server" TextMode="MultiLine" Enabled="false" CssClass="original-text" Visible="false" Height="120" />
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView2" runat="server">
                                <div id="multiPageDivTab2" class="multiPageDivTab" style="z-index: 9999;">
                                    <fieldset>
                                        <legend>New text</legend>
                                        <table class="rptSummaryText10 path-results-tab-table">
                                            <tr>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <telerik:RadTextBox ID="CommentsTextBox" runat="server" Skin="Metro" TextMode="MultiLine"
                                                        Width="600" MaxLength="65000" Height="80" />
                                                </td>
                                                <td>
                                                    <img src="../Images/phrase_library.png" style="padding-left: 5px" onclick="javascript:showPathLibrary('PathCommentRep');return false;" title="Phrases" /></td>
                                            </tr>
                                            <tr>
                                                <td style="height: 10px;"></td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                    <fieldset style="visibility:hidden;">
                                        <legend>Original Text</legend>
                                        <telerik:RadTextBox ID="AdviceCommentsOriginalTextRadTextBox" runat="server" TextMode="MultiLine" Enabled="false" CssClass="original-text" Visible="false" Height="120" />
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </td>
            </tr>
            <tr>
                <td style="padding-left: 21px;">
                    <telerik:RadButton ID="PathologyPreviewRadButton" runat="server" Text="Print Revised Report" Skin="Metro" OnClick="PathologyPreviewRadButton_Click" />

                </td>
            </tr>
            <tr>
                <td style="padding-left: 40%;">
                    <div style="height: 10px; padding-top: 10px;">
                        <span style="float: left; padding-right: 15px">
                            <telerik:RadButton ID="SavePathologyResultsRadButton" runat="server" Text="Save" Skin="Metro" OnClick="SavePathologyResultsRadButton_Click" Icon-PrimaryIconCssClass="telerikOkButton" />
                        </span>
                        <span style="float: left">
                            <telerik:RadButton ID="CancelSavePathologyResultsRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="setNewProcedureTab" Icon-PrimaryIconCssClass="telerikCancelButton" />
                        </span>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</div>

<script type="text/javascript">
    function OpenPreviewWindow(procId, labReportNo, reportDate) {
        var url = "<%= ResolveUrl("~/Products/Common/PrintReport.aspx") %>";
        url = url + "?PrintGPReport=1";
        url = url + "&PrintPhotosReport=0";
        url = url + "&PrintPatientCopyReport=0";
        url = url + "&PrintLabRequestReport=0";
        url = url + "&Resected=0";
        url = url + "&ReturnToPage=0";
        url = url + "&PreviewOnly=1";
        url = url + "&DeleteMedia=0";
        url = url + "&GPCopies=1";
        url = url + "&PhotosCopies=0";
        url = url + "&PatientCopies=0";
        url = url + "&LabCopies=0";
        url = url + "&PhotosOnGP=1";

        //var url = "<%= ResolveUrl("~/Products/Common/PathologyPreview.aspx") %>";
        //var oWnd = $find("<%= PreviewWindow.ClientID %>");
        
        //url = url + "?ProcedureID=" + procId;
        //url = url + "&ReportDate=" + reportDate;
        //url = url + "&LabReportNo=" + labReportNo;
        
        //oWnd.SetSize(850, 900);
        //oWnd._navigateUrl = url;
        //oWnd.show();
        //oWnd.moveTo(283, 0);

        var win = radopen(url, "Pathology Preview", "850px", "800px");
        win.set_visibleStatusbar(false);
        win.add_close();
    }

    function OnClientClosePreviewHandler(sender, args) {

    }

    function showContentForIE(wnd) {
        if ($telerik.isIE)
            wnd.view.onUrlChanged();
    }

    /*Pathology Results Popup Window Functions*/
    function BuildFurtherProcText() {
        var proc, periodCount, periodType, period, newtxt, oldtxt;
        proc = $("#<%= FurtherProcedureComboBox.ClientID%>").val();
        periodCount = $("#<%= FurtherProcedureDueCountNumericTextBox.ClientID%>").val();
        periodType = $("#<%= FurtherProcedureDueTypeComboBox.ClientID%>").val();
        oldtxt = $find("<%= FurtherProcedureTextBox.ClientID%>").get_value();

        newtxt = "";
        period = "";
        if (proc == "undefined") { proc = ""; }
        if (periodCount == "undefined") { periodCount = ""; }
        if (periodType == "undefined") { periodType = ""; }
        if (periodCount != "" && periodType != "") { period = "in " + periodCount + " " + periodType }

        if (proc != "" && period != "") {
            newtxt = proc + " " + period;
        }
        else if (proc != "") {
            newtxt = proc;
        }

        if (newtxt != "") {
            if (oldtxt != "") {
                oldtxt = oldtxt.replace(" and ", ", ")
                newtxt = oldtxt + " and " + newtxt;
            }
            $find("<%= FurtherProcedureTextBox.ClientID%>").set_value(newtxt);
        }

        //MH commented out on 14 Jan 2024 - No need to clear combo box, these values will be saved in table and will be shown later when page is loaded
        //ClearComboBox("<%= FurtherProcedureComboBox.ClientID%>");
        //ClearComboBox("<%= FurtherProcedureDueTypeComboBox.ClientID %>");
        //$("#<%= FurtherProcedureDueCountNumericTextBox.ClientID%>").val("");

        FurtherProcedureTab();
    }

    function BuildFollowUpText() {
        var returnTo, noFollowUp, reviewLoc, reviewDueCount, reviewDueType, returntxt, reviewtxt, newtxt;
        returnTo = $("#<%= ReturnToComboBox.ClientID%>").val();
        noFollowUp = $("#<%= NoFurtherFollowUpCheckBox.ClientID%>").is(':checked');
        reviewLoc = $("#<%= ReviewLocationComboBox.ClientID%>").val();
        reviewDueCount = $("#<%= ReviewDueCountNumericTextBox.ClientID%>").val();
        reviewDueType = $("#<%= ReviewDueTypeComboBox.ClientID%>").val();

        returntxt = "";
        reviewtxt = "";
        newtxt = "";
        if (returnTo == "undefined") { returnTo = ""; }
        if (reviewLoc == "undefined") { reviewLoc = ""; }
        if (reviewDueCount == "undefined") { reviewDueCount = ""; }
        if (reviewDueType == "undefined") { reviewDueType = ""; }

        if (returnTo != "") { returntxt = "Return to the " + returnTo; }
        if (noFollowUp) {
            reviewtxt = "no further follow up"
        }
        else {
            if (reviewDueCount != "" && reviewDueType != "") { reviewtxt = "in " + reviewDueCount + " " + reviewDueType }
            if (reviewLoc != "") { reviewtxt = "in the " + reviewLoc + " " + reviewtxt; }

            if (reviewtxt != "") { reviewtxt = "review will be " + reviewtxt; }
        }


        if (returntxt != "" && reviewtxt != "") { newtxt = returntxt + " and " + reviewtxt; }
        else if (returntxt != "") { newtxt = returntxt; }
        else if (reviewtxt != "") { newtxt = reviewtxt; }

        if (newtxt != "") {
            $find("<%= ReviewTextBox.ClientID%>").set_value(newtxt);
        }
        FollowUpTab();
        //TODO - hide review row when checkbox is checked
    }

    function FurtherProcedureTab() {
        var apply = false;

        $("#multiPageDivTab").find('textarea').each(function () {
            if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
        });

        setImage("0", apply);
    }

    function FollowUpTab() {
        var apply = false;
        $("#multiPageDivTab1").find("input[type=text], select, textarea").each(function () {
            if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(Unspecified)' && $(this).val() != '(none)' && $(this).val() != 'day(s)') { apply = true; return false; }
        });
        if ($("#multiPageDivTab1 input:checkbox:checked").length > 0) { apply = true; }
        setImage("1", apply);
    }

    function AdviceTab() {
        var apply = false;
        $("#multiPageDivTab2").find('textarea').each(function () {
            if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
        });

        setImage("2", apply);
    }

    function setImage(ind, state) {
        var tabS = $find("<%= RadTabStrip1.ClientID%>");
        var tab = tabS.findTabByValue(ind);
        if (tab != null) {
            if (state) {
                tab.set_imageUrl('../../../../Images/Ok.png');

            } else {

                tab.set_imageUrl("../../../../Images/none.png");
            }
        }
    }

    function CalledPathFn(data, ops) {
        if (ops == 'PathFollowUp') {
            $find("<%= ReviewTextBox.ClientID%>").set_value(data);
        } else if (ops == 'PathCommentRep') {
            $find("<%= CommentsTextBox.ClientID%>").set_value(data);
        } else if (ops == 'PathPathFurtherProc') {
            $find("<%= FurtherProcedureTextBox.ClientID%>").set_value(data);
        }
    }

    function showPathLibrary(details) {
        if (details == 'PathFurtherProc') {
            var btn = $find("<%= FurtherProcedureTextBox.ClientID%>");
            var win = radopen("Common/WordLibrary.aspx?option=PathFurtherProc&msg=" + btn.get_value(), "Word Library", "710px", "610px");
            win.set_visibleStatusbar(false);
            win.add_close();
            win.set_behaviors(null);
            win.add_close(FurtherProcedureTab);
        } else if (details == 'PathPathFollowUp') {
            var btn = $find("<%= ReviewTextBox.ClientID%>");
            var win = radopen("Common/WordLibrary.aspx?option=PathFollowUp&msg=" + btn.get_value(), "Word Library", "710px", "610px");
            win.set_visibleStatusbar(false);
            win.add_close();
            win.set_behaviors(null);
            win.add_close(FollowUpTab);
        } else if (details == 'PathCommentRep') {
            var btn = $find("<%= CommentsTextBox.ClientID%>");
            var win = radopen("Common/WordLibrary.aspx?option=PathCommentRep&msg=" + btn.get_value(), "Word Library", "710px", "610px");
            win.set_visibleStatusbar(false);
            win.add_close();
            win.set_behaviors(null);
            win.add_close(AdviceTab);
        }
    }

    function ToggleReviewDetails(detailsControlId) {
        Toggle(!($(event.target).is(':checked')), detailsControlId);
    }

</script>

