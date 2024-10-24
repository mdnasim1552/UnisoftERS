<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="FurtherProcedures.ascx.vb" Inherits="UnisoftERS.FurtherProcedures" %>
<style type="text/css">
    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

    .comorb-child {
        margin-left: 10px;
        display: none;
    }
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">

        window.onbeforeunload = function (event) {

        }

        $(document).ready(function () {

            $('.furtherprocedures-text-input').on('focusout', function () {
                saveFurtherProcedures();
            });
        });        


        //function CancerScreeningTab() {

        //    var apply = false;

        //    $("#multiPageDivTab").find('textarea').each(function () {
        //        if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(Unspecified)' && $(this).val()) { apply = true; return false; }
        //    });

        //    if ($("#multiPageDivTab input:checkbox:checked").length > 0) { apply = true; }

        //    setImage("1", apply);

        //    displayCancerEvidenceDetails();
        //}

   

      

        function BuildFurtherProcText() {
            var proc, periodCount, periodType, period, newtxt, oldtxt,risk;
            proc = $("#<%= FurtherProcedureComboBox.ClientID%>").val();
            periodCount = $("#<%= FurtherProcedureDueCountNumericTextBox.ClientID%>").val();
            periodType = $("#<%= FurtherProcedureDueTypeComboBox.ClientID%>").val();
            oldtxt = $find("<%= FurtherProcedureTextBox.ClientID%>").get_value();    
            risk = $("#<%= RiskCategoriesComboBox.ClientID%>").val();
            newtxt = "";
                period = "";
                if (proc == "undefined") { proc = ""; }
                if (periodCount == "undefined") { periodCount = ""; }
                if (periodType == "undefined") { periodType = ""; }
                if (periodCount != "" && periodType != "") { period = "in " + periodCount + " " + periodType }
                if (risk == "undefined") { risk = ""; }
            if (proc != "" && period != "" && risk != "") {
                newtxt = proc + " " + period + " at " + risk;
            }
            else if (proc != "" && risk != "") {
                newtxt = proc + " at " + risk;
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
            if (newtxt != "" ) {
                if (oldtxt != "") {
                    oldtxt = oldtxt.replace(" and ", ", ")
                    newtxt = oldtxt + " and " + newtxt;
                }
                $find("<%= FurtherProcedureTextBox.ClientID%>").set_value(newtxt);
            }
            saveFurtherProcedures();
            ClearComboBox("<%= FurtherProcedureComboBox.ClientID%>");
            ClearComboBox("<%= FurtherProcedureDueTypeComboBox.ClientID %>");
            ClearComboBox("<%= RiskCategoriesComboBox.ClientID %>");
            $("#<%= FurtherProcedureDueCountNumericTextBox.ClientID%>").val("");
        }



        function ToggleCancerDetails(detailsControlId) {
            Toggle(!($(event.target).is(':checked')), detailsControlId);
        }

        function ToggleReviewDetails(detailsControlId) {
            Toggle(!($(event.target).is(':checked')), detailsControlId);
        }

        function CalledFurtherProceduresFn(data, ops) {
            if (ops == 'FurtherProc') {
                $find("<%= FurtherProcedureTextBox.ClientID%>").set_value(data);
            }
            saveFurtherProcedures();
        }

        function showFurtherProceduresLibrary(details) {
            if (details == 'FurtherProc') {
                var btn = $find("<%= FurtherProcedureTextBox.ClientID%>");
                var win = radopen("../Products/Common/WordLibrary.aspx?option=FurtherProc&msg=" + btn.get_value(), "Word Library", "710px", "610px");
                win.set_visibleStatusbar(false);
                win.add_close();
                win.set_behaviors(null);
                
            }
        }

        function saveFurtherProcedures() {
            var obj = {};            
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.procedureTypeId = parseInt(<%= procType %>);            
            obj.furtherProcedureTypeId = parseInt($find("<%= FurtherProcedureComboBox.ClientID%>").get_value());  
            obj.riskCategoriesTypeId = parseInt($find("<%= RiskCategoriesComboBox.ClientID%>").get_value());
            obj.furtherProcedureTypeText = (obj.furtherProcedureTypeId = -99) ? $find("<%= FurtherProcedureComboBox.ClientID%>").get_text() : '';            
            obj.furtherProcedureText = $find("<%= FurtherProcedureTextBox.ClientID%>").get_textBoxValue();
            if (isNaN($find("<%= FurtherProcedureDueTypeComboBox.ClientID%>").get_value()) || $find("<%= FurtherProcedureDueTypeComboBox.ClientID%>").get_value()=='') {
                obj.furtherProcedureDueTypeId = 0;       
            } else {                
                obj.furtherProcedureDueTypeId = parseInt($find("<%= FurtherProcedureDueTypeComboBox.ClientID%>").get_value());       
            }
            if (obj.riskCategoriesTypeId == -1 || obj.riskCategoriesTypeId == '')
            {
                obj.riskCategoriesTypeId = null;
            }
            obj.FurtherProcedureDueTypeText = (obj.furtherProcedureDueTypeId ) ? $find("<%= FurtherProcedureDueTypeComboBox.ClientID%>").get_text() : '';            
            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/saveFurtherProcedures",
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
    <table class="rptSummaryText10" cellpadding="3" cellspacing="3">
        <tr>
            <td>
                <telerik:RadComboBox ID="FurtherProcedureComboBox" runat="server" Skin="Metro" Width="200"
                    Style="margin-right: 5px;" />
                in
                &nbsp;&nbsp;
                <telerik:RadNumericTextBox ID="FurtherProcedureDueCountNumericTextBox" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MaxValue="52"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <telerik:RadComboBox ID="FurtherProcedureDueTypeComboBox" runat="server" Skin="Metro" Width="80"   
                    Style="margin-right: 5px;" />
                 <telerik:RadComboBox ID="RiskCategoriesComboBox" runat="server" Style="margin-left: 7px;" Width="140" Skin="Windows7" CssClass="risk-categories-css">
   </telerik:RadComboBox>
                <telerik:RadButton ID="FurtherProcedureBuildTextButton" runat="server" Text="Add" Skin="Metro"
                    AutoPostBack="false" OnClientClicked="BuildFurtherProcText" Style="margin-left: 7px;"/>
            </td>
        </tr>

        <tr>
            <td>
                <telerik:RadTextBox ID="FurtherProcedureTextBox" runat="server" Skin="Metro" TextMode="MultiLine" CssClass="furtherprocedures-text-input"
                    Width="1000" Height="96" MaxLength="1000"  />
                <img src="../Images/phrase_library.png" style="padding-left: 5px" onclick="javascript:showFurtherProceduresLibrary('FurtherProc');return false;" title="Phrases" /> 
            </td>
        </tr>
    </table>
</div>
