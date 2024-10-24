<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="LevelOfComplexity.ascx.vb" Inherits="UnisoftERS.LevelOfComplexity" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(document).ready(function () {
            
            $('.complexity-level-rb input[type=radio]').on('change', function () {
                var selectedValue = $('input[name="' + $(this).attr("name") + '"]:checked').val();
                saveProcedureComplexity(selectedValue);
            });
        });

        function saveProcedureComplexity(id) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.procedureComplexityId = parseInt(id);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveLevelOfComplexity",
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
<div class="control-sub-header">Level of complexity</div>
<div class="control-content">
     <asp:RadioButtonList id="ComplexityRadioButtonList" CssClass="complexity-level-rb" Width="100%" runat="server" ClientIDMode="Static">
     </asp:RadioButtonList>
</div>