<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="FollowUp.ascx.vb" Inherits="UnisoftERS.FollowUp" %>
<style type="text/css">
    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">

        window.onbeforeunload = function (event) {

        }

        $(window).on('load', function () {
            Toggle(!($("#<%= NoFurtherFollowUpCheckBox.ClientID%>").is(':checked')), 'ReviewTR');
            //displayReBleedOther();
            //CancerScreeningTab();
            //FurtherProcedureTab();
            //FollowUpTab();
            //AdviceTab();
            //CopyToTab();
        });

        $(document).ready(function () {

            $('.followup-text-input').on('focusout', function () {
                saveFollowUp();
            });

            $('.followup-check-box').on('change', function () {
                saveFollowUp();
            });

        });

 
        function BuildFollowUpText() {
           
            var returnTo, noFollowUp, reviewLoc, reviewDueCount, reviewDueType, returntxt, reviewtxt, newtxt;
            returnTo = $("#<%= ReturnToComboBox.ClientID%>").val();
            noFollowUp = $("#<%= NoFurtherFollowUpCheckBox.ClientID%>").is(':checked');
            reviewLoc = $("#<%= ReviewLocationComboBox.ClientID%>").val();
            reviewDueCount = $("#<%= ReviewDueCountNumericTextBox.ClientID%>").val();
            reviewDueType = $("#<%= ReviewDueTypeComboBox.ClientID%>").val();
            newtxt = "";
                returntxt = "";
                reviewtxt = "";              
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
           
            //TODO - hide review row when checkbox is checked
            saveFollowUp();
        }

        function ToggleCancerDetails(detailsControlId) {
            Toggle(!($(event.target).is(':checked')), detailsControlId);
        }

        function ToggleReviewDetails(detailsControlId) {
            Toggle(!($(event.target).is(':checked')), detailsControlId);
        }
        function noFurtherFollowUp() {
             // by Ferdowsi   , removing text box value
            if ($('#<%= NoFurtherFollowUpCheckBox.ClientID %>').prop('checked')) {
                $find("<%= ReviewTextBox.ClientID%>").set_value("");
                $('#<%= ReviewTR.ClientID %>').hide();

            } else {
                $('#<%= ReviewTR.ClientID %>').show();
            }
        }

        function CalledFollowUpFn(data, ops) {
            if (ops == 'FollowUp') {
                $find("<%= ReviewTextBox.ClientID%>").set_value(data);
                saveFollowUp();
            }
        }

        function showFollowUpLibrary(details) {
            if (details == 'FollowUp') {
                var btn = $find("<%= ReviewTextBox.ClientID%>");
                var win = radopen("../Products/Common/WordLibrary.aspx?option=FollowUp&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                //win.add_close(FollowUpTab);
            }
        }

        function saveFollowUp() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.procedureTypeId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE) %>);
            obj.noFurtherTests = $('#<%= chkNoFurtherTestsCheckBox.ClientID %>').is(':checked');
            obj.awaitingPathologyResults = $("#<%= chkAwaitingPathologyResultsCheckBox.ClientID%>").is(':checked');
            obj.returnToId = ($find("<%= ReturnToComboBox.ClientID%>").get_value() == '') ? 0 : parseInt($find("<%= ReturnToComboBox.ClientID%>").get_value());
            obj.returnToText = (obj.returnToId = -99) ? $find("<%= ReturnToComboBox.ClientID%>").get_text() : '';
            obj.noFurtherFollowUp = $("#<%= NoFurtherFollowUpCheckBox.ClientID%>").is(':checked');
            obj.reviewLocationId = ($find("<%= ReviewLocationComboBox.ClientID%>").get_value() == '') ? 0 : parseInt($find("<%= ReviewLocationComboBox.ClientID%>").get_value());
            obj.reviewLocationText = (obj.reviewLocationId = -99) ? $find("<%= ReviewLocationComboBox.ClientID%>").get_text() : '';
            obj.reviewDueTypeId = ($find("<%= ReviewDueTypeComboBox.ClientID%>").get_value() == '') ? 0 : parseInt($find("<%= ReviewDueTypeComboBox.ClientID%>").get_value());
            obj.reviewText = $find("<%= ReviewTextBox.ClientID%>").get_textBoxValue();

            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/saveFollowUp",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }
    </script>
</telerik:RadScriptBlock>


<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />


<div class="control-content">
    <div style="margin-top: 10px; margin-bottom: 20px;">
        <asp:CheckBox ID="chkNoFurtherTestsCheckBox" runat="server" Text="No further tests" CssClass="followup-check-box" />
        &nbsp;&nbsp;&nbsp;&nbsp;
                                    <asp:CheckBox ID="chkAwaitingPathologyResultsCheckBox" runat="server" CssClass="followup-check-box" Text="Awaiting pathology results" />
    </div>
    <table class="rptSummaryText10" cellpadding="3" cellspacing="3">
        <tr>
            <td style="width: 125px;">Return to the
            </td>
            <td>
                <telerik:RadComboBox ID="ReturnToComboBox" runat="server" Skin="Metro" Width="200" OnClientSelectedIndexChanged="saveFollowUp" />
            </td>
        </tr>
        <tr>
            <td>No further follow up 
            </td>
            <td>
                <asp:CheckBox ID="NoFurtherFollowUpCheckBox" runat="server" Text="" Style="margin-left: -2px;" CssClass="followup-check-box"
                    onchange="noFurtherFollowUp();" />
            </td>
        </tr>
        <tr id="ReviewTR" runat="server" style="display: none;">
            <td>Review will be in the
            </td>
            <td>
                <telerik:RadComboBox ID="ReviewLocationComboBox" runat="server" Skin="Metro" Width="130" />
                &nbsp;
                                                in
                                                &nbsp;
                                                <telerik:RadNumericTextBox ID="ReviewDueCountNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MaxValue ="52"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                <telerik:RadComboBox ID="ReviewDueTypeComboBox" runat="server" Skin="Metro" Width="80"  
                    Style="margin-right: 5px;" />
                <telerik:RadButton ID="ReviewBuildTextButton" runat="server" Text="Add" Skin="Metro"
                    AutoPostBack="false" OnClientClicked="BuildFollowUpText"  />
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <telerik:RadTextBox ID="ReviewTextBox" runat="server" Skin="Metro" TextMode="MultiLine" CssClass="followup-text-input"
                    Width="1000" Height="96" MaxLength="1000"  /><img src="../Images/phrase_library.png" style="padding-left: 5px"
                        onclick="javascript:showFollowUpLibrary('FollowUp');return false;" title="Phrases" />
            </td>
        </tr>
    </table>
</div>
