<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_FollowUp"
    CodeBehind="FollowUp.aspx.vb" ValidateRequest="false" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/Global.js"></script>
    <style type="text/css">
        .checkboxesTable td {
            padding-right: 10px;
            padding-bottom: 3px;
        }

        .rblRed Label {
            color: red !important;
        }
    </style>
    <script type="text/javascript">
        function getUrlParam(parameter, defaultvalue) {
            var urlparameter = defaultvalue;
            if (window.location.href.indexOf(parameter) > -1) {
                urlparameter = getUrlVars()[parameter];
            }
            return urlparameter;
        }
        function getUrlVars() {
            var vars = {};
            var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
                vars[key] = value;
            });
            return vars;
        }
        window.onbeforeunload = function (event) {
            document.getElementById("<%= SaveOnly.ClientID %>").click();
        }

        $(window).on('load', function () {
            Toggle(!($("#<%= NoFurtherFollowUpCheckBox.ClientID%>").is(':checked')), 'ReviewTR');
            displayReBleedOther();
            CancerScreeningTab();
            FurtherProcedureTab();
            FollowUpTab();
            AdviceTab();
            //CopyToTab();

            //Mahfuz added on 04 Oct 2021
            var tabValue = getUrlParam('tab', 1);
            //alert(tabValue);

            var tabStrip = $find("<%= RadTabStrip1.ClientID %>");
            var tab = tabStrip.findTabByValue(tabValue);

            //alert(tabStrip);

            if (tab) {
                //alert('selecting tab');
                tab.select();
            }


        });

        $(document).ready(function () {

            $("#multiPageDivTab").find("input[type=text],input:checkbox ,  select, textarea").change(function () {
                CancerScreeningTab();
            });
            $("#multiPageDivTab1").find('textarea').change(function () {
                FurtherProcedureTab();
            });
            $("#multiPageDivTab2").find("input[type=text],input:checkbox ,  select, textarea").change(function () {
                FollowUpTab();
            });
            $("#multiPageDivTab3").find('textarea').change(function () {
                AdviceTab();
            });
            //$("#multiPageDivTab3").find("input[type=text],input:checkbox , input:radio").change(function () {
            //    CopyToTab();
            //});

            $('#<%= rblCancerEvidence.ClientID %> input').change(function () {
                displayCancerEvidenceDetails();
            });


        });

        function CheckForValidPage() {
            var valid = Page_ClientValidate("FollowUp");
            if (!valid) {
                var lblEvidenceofCancer = document.getElementById("<%= lblEvidenceOfCancer.ClientID%>");
                lblEvidenceofCancer.innerHTML = "<span style='color:red;'>Evidence of cancer:</span>";
              
                $find("<%=CreateProcRadNotification.ClientID%>").show();
            }
            else {
                validatePage();
            }
        }

        function displayCancerEvidenceDetails() {

            var cancerEvidenceResponseSelected = $('#<%= rblCancerEvidence.ClientID %> input:checked').val();
            var patientInformedSelected = $("#<%= chkPatientInformed.ClientID%>").is(':checked');

            if (cancerEvidenceResponseSelected == 1 || cancerEvidenceResponseSelected == 2) {
                $("#PatientInformedDetails").show();
                if (patientInformedSelected == false) {
                    $("#ReasonWhyNotInformedTextBox").show();
                }
                else {
                    $("#ReasonWhyNotInformedTextBox").hide();
                }
                $("#FastTrackRemovedDetails").show();
                $("#CnsMdtcInformedDetails").show();
            } else if (cancerEvidenceResponseSelected == 3) {
                $("#PatientInformedDetails").hide();
                $("#ReasonWhyNotInformedTextBox").hide();
                $("#FastTrackRemovedDetails").hide();
                $("#CnsMdtcInformedDetails").hide();
            }
            if (cancerEvidenceResponseSelected == 1 || cancerEvidenceResponseSelected == 3) {
                $("#FastTrackRemovedDetails").hide();
            }
            else {
                $("#FastTrackRemovedDetails").show();
            }
        }


        function displayReBleedOther() {

            var reBleedPlanOtherResponseSelected = $('#<%= ReBleedPlanOtherCheckBox.ClientID %>').is(':checked');

            if (reBleedPlanOtherResponseSelected) {
                $('.ReBleedPlanOtherOptionTRClass').show();
            }
            else {
                $('.ReBleedPlanOtherOptionTRClass').hide();
                $('#<%= ReBleedPlanOtherOptionTextBox.ClientID %>').val('');

            }
        };

        function displayPatientInformedDetails() {
            var selectedValue = $("#<%= chkPatientInformed.ClientID%>").is(':checked');

            if (selectedValue) {
                $("#ReasonWhyNotInformedTextBox").hide();
            }
            else {
                $("#ReasonWhyNotInformedTextBox").show();
            }
        }

        function CancerScreeningTab() {

            var apply = false;

            $("#multiPageDivTab").find('textarea').each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(Unspecified)' && $(this).val()) { apply = true; return false; }
            });

            if ($("#multiPageDivTab input:checkbox:checked").length > 0) { apply = true; }

            setImage("1", apply);

            displayCancerEvidenceDetails();
        }

        function FurtherProcedureTab() {
            var apply = false;

            $("#multiPageDivTab1").find('textarea').each(function () {
                if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
            });

            setImage("1", apply);
        }

        function FollowUpTab() {
            var apply = false;
            $("#multiPageDivTab2").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(Unspecified)' && $(this).val() != '(none)'
                    && $(this).val() != 'day(s)' && $(this).val() != '0') { apply = true; return false; }
            });
            if ($("#multiPageDivTab2 input:checkbox:checked").length > 0) { apply = true; }

            setImage("2", apply);
        }

        function AdviceTab() {
            var apply = false;
            $("#multiPageDivTab3").find('textarea').each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });

            setImage("3", apply);
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

        <%--function BuildCancerScreeningText() {
            var noTests, awaitPathResults, evidenceCancerIdentified, patientInformed, patientRemovedFastTrack, reasonWhyNotInformed, cnsMdtcInformed
            noTests = $("#<%= chkNoFurtherTestsCheckBox.ClientID%>").is(':checked');
            awaitPathResults = $("#<%= chkAwaitingPathologyResultsCheckBox.ClientID%>").is(':checked');
            evidenceCancerIdentified = $('#rblCancerEvidence input:checked').val();
            patientInformed = $("#<%= chkPatientInformed.ClientID%>").is(':checked');
            patientRemovedFastTrack = $("#<%= chkFastTrackRemoved.ClientID%>").is(':checked');
            reasonWhyNotInformed = $find("<%= txtReasonWhyNotInformed.ClientID%>").get_value();
            cnsMdtcInformed = $("#<%= chkCnsMdtcInformed.ClientID%>").is(':checked');
            
            CancerScreeningTab();
        }--%>

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

            //check if new item has been added to the list and save if so
            var obj = {};

            obj.procedureTypeId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>);
            obj.text = proc;

            if ($find("<%= FurtherProcedureComboBox.ClientID%>").get_value() == "-99") {
                $.ajax({
                    type: "POST",
                    url: "Followup.aspx/SaveNewFollowUpProcedure",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {

                    },
                    error: function (x, y, z) {
                        console.log(x.responseXML);
                    }
                });
            }

            if (newtxt != "") {
                if (oldtxt != "") {
                    oldtxt = oldtxt.replace(" and ", ", ")
                    newtxt = oldtxt + " and " + newtxt;
                }
                $find("<%= FurtherProcedureTextBox.ClientID%>").set_value(newtxt);
            }



            ClearComboBox("<%= FurtherProcedureComboBox.ClientID%>");
            ClearComboBox("<%= FurtherProcedureDueTypeComboBox.ClientID %>");
            $("#<%= FurtherProcedureDueCountNumericTextBox.ClientID%>").val("");
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

        function ToggleCancerDetails(detailsControlId) {
            Toggle(!($(event.target).is(':checked')), detailsControlId);
        }

        function ToggleReviewDetails(detailsControlId) {
            Toggle(!($(event.target).is(':checked')), detailsControlId);
        }

        function CalledFn(data, ops) {
            if (ops == 'FollowUp') {
                $find("<%= ReviewTextBox.ClientID%>").set_value(data);
            } else if (ops == 'CommentRep') {
                $find("<%= CommentsTextBox.ClientID%>").set_value(data);
            } else if (ops == 'FriendlyRep') {
                $find("<%= PfrFollowUpTextBox.ClientID%>").set_value(data);
            } else if (ops == 'FurtherProc') {
                $find("<%= FurtherProcedureTextBox.ClientID%>").set_value(data);
            }
        }

        function showLibrary(details) {
            if (details == 'FurtherProc') {
                var btn = $find("<%= FurtherProcedureTextBox.ClientID%>");
                var win = radopen("../../../Common/WordLibrary.aspx?option=FurtherProc&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                win.add_close(FurtherProcedureTab);
            } else if (details == 'FollowUp') {
                var btn = $find("<%= ReviewTextBox.ClientID%>");
                var win = radopen("../../../Common/WordLibrary.aspx?option=FollowUp&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                win.add_close(FollowUpTab);
            } else if (details == 'CommentRep') {
                var btn = $find("<%= CommentsTextBox.ClientID%>");
                var win = radopen("../../../Common/WordLibrary.aspx?option=CommentRep&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                win.add_close(AdviceTab);
            } else if (details == 'FriendlyRep') {
                var btn = $find("<%= PfrFollowUpTextBox.ClientID%>");
                var win = radopen("../../../Common/WordLibrary.aspx?option=FriendlyRep&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                win.add_close(AdviceTab);
            }
        }

    </script>
</asp:Content>
<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="divFollowUp"
        Skin="Web20" />
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">
            function HideLoading() {
                var url = window.location.href;
                if (url.indexOf('?') > -1) {
                    if (url.indexOf('from=') > -1) {
                        if (url.indexOf('js=') < 0) {
                            url += '&js=1';
                        }
                    } else {
                        url += '&from=validation&js=1';
                    }

                } else {
                    url += '?from=validation&js=1';
                }
                window.location.href = url;
            }

        </script>
    </telerik:RadCodeBlock>
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0"
        PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <div id="ContentDiv" runat="server">
                <div>
                    <telerik:RadNotification ID="CreateProcRadNotification" runat="server" Animation="None"
                        EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                        LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
                        AutoCloseDelay="7000">
                        <ContentTemplate>
                            <asp:ValidationSummary ID="ValidationSummary" runat="server" ValidationGroup="FollowUp" DisplayMode="BulletList"
                                EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                        </ContentTemplate>
                    </telerik:RadNotification>
                </div>
                <div class="otherDataHeading">
                    <b>Follow Up</b>
                </div>
                <div id="divFollowUp" style="margin: 5px 10px;">

                    <div style="margin-left: 20px;">

                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true"
                            Skin="Metro"
                            Orientation="HorizontalTop" RenderMode="Lightweight">
                            <Tabs>
                                <telerik:RadTab Text="Further Procedure(s)" Font-Bold="true" Value="1" />
                                <telerik:RadTab Text="Follow Up" Font-Bold="true" Value="2" />
                                <telerik:RadTab Text="Advice / Comments" Font-Bold="true" Value="3" />
                            </Tabs>
                        </telerik:RadTabStrip>

                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="multiPageDivTab1" class="multiPageDivTab">
                                    <table class="rptSummaryText10" cellpadding="3" cellspacing="3">
                                        <tr>
                                            <td>
                                                <telerik:RadComboBox ID="FurtherProcedureComboBox" runat="server" Skin="Windows7" Width="200"
                                                    Style="margin-right: 5px;" />
                                                in
                                                &nbsp;&nbsp;
                                                <telerik:RadNumericTextBox ID="FurtherProcedureDueCountNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                <telerik:RadComboBox ID="FurtherProcedureDueTypeComboBox" runat="server" Skin="Windows7" Width="80"
                                                    Style="margin-right: 5px;" />
                                                <telerik:RadButton ID="FurtherProcedureBuildTextButton" runat="server" Text="Add" Skin="WebBlue"
                                                    AutoPostBack="false" OnClientClicked="BuildFurtherProcText" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadTextBox ID="FurtherProcedureTextBox" runat="server" Skin="Windows7" TextMode="MultiLine"
                                                    Width="500" Height="80" /><img src="../../../../Images/phrase_library.png" style="padding-left: 5px"
                                                        onclick="javascript:showLibrary('FurtherProc');return false;" title="Phrases" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView2" runat="server">
                                <div id="multiPageDivTab2" class="multiPageDivTab">
                                    <div style="margin-top: 10px; margin-bottom: 20px;">
                                        <asp:CheckBox ID="chkNoFurtherTestsCheckBox" runat="server" Text="No further tests" />
                                        &nbsp;&nbsp;&nbsp;&nbsp;
                                    <asp:CheckBox ID="chkAwaitingPathologyResultsCheckBox" runat="server" Text="Awaiting pathology results" />
                                    </div>
                                    <table class="rptSummaryText10" cellpadding="3" cellspacing="3">
                                        <tr>
                                            <td style="width: 125px;">Return to the
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="ReturnToComboBox" runat="server" Skin="Windows7" Width="200" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>No further follow up
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="NoFurtherFollowUpCheckBox" runat="server" Text="" Style="margin-left: -2px;"
                                                    onchange="ToggleReviewDetails('ReviewTR');" />
                                            </td>
                                        </tr>
                                        <tr id="ReviewTR" runat="server" style="display: none;">
                                            <td>Review will be in the
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="ReviewLocationComboBox" runat="server" Skin="Windows7" Width="130" />
                                                &nbsp;
                                                in
                                                &nbsp;
                                                <telerik:RadNumericTextBox ID="ReviewDueCountNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0"
                                                    MaxValue="31"
                                                    MaxLength="2">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                <telerik:RadComboBox ID="ReviewDueTypeComboBox" runat="server" Skin="Windows7" Width="80"
                                                    Style="margin-right: 5px;" />
                                                <telerik:RadButton ID="ReviewBuildTextButton" runat="server" Text="Add" Skin="WebBlue"
                                                    AutoPostBack="false" OnClientClicked="BuildFollowUpText" />
                                            </td>

                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <telerik:RadTextBox ID="ReviewTextBox" runat="server" Skin="Windows7" TextMode="MultiLine"
                                                    Width="500" Height="80" /><img src="../../../../Images/phrase_library.png" style="padding-left: 5px"
                                                        onclick="javascript:showLibrary('FollowUp');return false;" title="Phrases" />
                                            </td>
                                        </tr>
                                    </table>
                                    <asp:RangeValidator ID="RadNumericTextBoxRangeValidator"
                                        ControlToValidate="ReviewDueCountNumericTextBox"
                                        MinimumValue="0"
                                        MaximumValue="31"
                                        Type="Integer"
                                        EnableClientScript="false"
                                        Text="The value must be from 1 to 31"
                                        runat="server" />
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView3" runat="server">
                                <div id="multiPageDivTab3" class="multiPageDivTab">
                                    <table class="rptSummaryText10" cellpadding="3" cellspacing="3">
                                        <tr>
                                            <td>
                                                <label id="lblEvidenceOfCancer" runat="server">Evidence of cancer:</label>
                                                <asp:RadioButtonList ID="rblCancerEvidence" runat="server" onclick="displayCancerEvidenceDetails();"
                                                    CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                    <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="No"></asp:ListItem>
                                                    <asp:ListItem Value="3" Text="Unknown"></asp:ListItem>
                                                </asp:RadioButtonList>
                                                <asp:RequiredFieldValidator ID="EvidenceOfCancerFieldValidator" runat="server" ControlToValidate="rblCancerEvidence" Display="None" ErrorMessage="Evidence of Cancer Mandatory, please provide Yes or No" ValidationGroup="FollowUp" />

                                            </td>
                                        </tr>
                                        <tr id="PatientInformedDetails">
                                            <td>
                                                <asp:CheckBox ID="chkPatientInformed" runat="server" Text="Patient informed" onchange="displayPatientInformedDetails();" />
                                            </td>
                                        </tr>
                                        <tr id="ReasonWhyNotInformedTextBox">
                                            <td>&nbsp; &nbsp;
                                                <telerik:RadTextBox ID="txtReasonWhyNotInformed" runat="server" Skin="Windows7" TextMode="SingleLine"
                                                    EmptyMessage="Reason why patient is not informed" Width="482" Height="20" />
                                            </td>
                                        </tr>
                                        <tr id="FastTrackRemovedDetails">
                                            <td>
                                                <asp:CheckBox ID="chkFastTrackRemoved" runat="server" Text="Patient Removed from 2 week rule pathway" />
                                            </td>
                                        </tr>
                                        <tr id="CnsMdtcInformedDetails">
                                            <td>
                                                <asp:CheckBox ID="chkCnsMdtcInformed" runat="server" Text="CNS/MDTC informed" />
                                            </td>
                                        </tr>
                                        <tr id="ImagingRequested">
                                            <td>
                                                <asp:CheckBox ID="chkImagingRequested" runat="server" Text="Imaging has been requested" />
                                            </td>
                                        </tr>
                                    </table>
                                    <div id="ReBleedPlanDiv" runat="server">
                                        <table id="ReBleedPlanTable" class="reBleedPlan">
                                            <tr>
                                                <td>
                                                    <label>RE-Bleed plan:</label>
                                                    <asp:CheckBox ID="ReBleedPlanRepeatGastroCheckBox" runat="server" Text="Repeat gastroscopy"></asp:CheckBox>
                                                    <asp:CheckBox ID="ReBleedPlanReqSurgRevCheckBox" runat="server" Text="Request surgical review"></asp:CheckBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ReBleedPlanOtherCheckBox" runat="server" Text="Other (please specify)" onclick="displayReBleedOther()" />
                                                    <%--onchange="ToggleReviewDetails('ReBleedPlanOtherOptionTR');" />--%>
                                                </td>
                                            </tr>
                                            <tr id="ReBleedPlanOtherOptionTR" class="ReBleedPlanOtherOptionTRClass">
                                                <td>
                                                    <asp:TextBox ID="ReBleedPlanOtherOptionTextBox" class="ReBleedPlanOtherOptionClass" runat="server" Visible="true"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>

                                    <table>
                                        <tr id="ClinicalFindingAlert">
                                            <td>
                                                <asp:CheckBox ID="chkFindingAlert" runat="server" Text="Clinical findings alert" />
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="rptSummaryText10">
                                        <tr>
                                            <td>Printed at the end of the report</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadTextBox ID="CommentsTextBox" runat="server" Skin="Windows7" TextMode="MultiLine"
                                                    Width="500" Height="60" /><img src="../../../../Images/phrase_library.png" style="padding-left: 5px"
                                                        onclick="javascript:showLibrary('CommentRep');return false;" title="Phrases" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 10px;"></td>
                                        </tr>
                                        <tr>
                                            <td>To be included in the patient friendly report</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadTextBox ID="PfrFollowUpTextBox" runat="server" Skin="Windows7" TextMode="MultiLine"
                                                    Width="500" Height="60" /><img src="../../../../Images/phrase_library.png" style="padding-left: 5px"
                                                        onclick="javascript:showLibrary('FriendlyRep');return false;" title="Phrases" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>

                        </telerik:RadMultiPage>
                    </div>
                </div>
            </div>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" ValidationGroup="FollowUp" OnClientClicked="CheckForValidPage"
                    Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
            <div style="height: 0px; display: none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" Style="height: 1px; width: 1px" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>

