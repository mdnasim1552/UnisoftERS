<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Allergies.ascx.vb" Inherits="UnisoftERS.Allergies" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        $(window).on('load', function () {

        });

        $(document).ready(function () {
            ToggleAllergyDescTextBox();

            $('.allergy-options input').on('change', function ()
            {
                ToggleAllergyDescTextBox();
                saveAllergy($('.allergy-options input:checked').val(), $('.allergy-description').val());
            });

            $('.allergy-description').on('focusout', function () {
                var allergyResult = $('.allergy-options input:checked').val();
                var allergyDescription = $('.allergy-description').val();
                saveAllergy(allergyResult, allergyDescription);
            });
        });

        function saveAllergy(allergyResult, allergyDescription) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.patientId = parseInt(getCookie('patientId'));
            obj.allergyResult = parseInt(allergyResult);
            obj.allergyDescription = allergyDescription;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveAllergy",
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

        function ToggleAllergyDescTextBox()
        {
            var allergyResult = $('.allergy-options input:checked').val();
            if (parseInt(allergyResult) == 1)
            {
                $("#<%= AllergyDescTextBox.ClientID%>").show();
            }
            else
            {
                $("#<%= AllergyDescTextBox.ClientID%>").hide();
                $('#<%= AllergyDescTextBox.ClientID%>').val("");
            }
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader">Allergies</div>
<div class="control-content">
    <table>
        <tr>
            <td>
                <asp:RadioButtonList ID="AllergyRadioButtonList" runat="server" RepeatDirection="Vertical" CssClass="allergy-options">
                    <asp:ListItem Text="Unknown" Value="-1" />
                    <asp:ListItem Text="None" Value="0" />
                    <asp:ListItem Text="Yes" Value="1" />
                </asp:RadioButtonList>
            </td>
            <td style="vertical-align: bottom;">
                <telerik:RadTextBox ID="AllergyDescTextBox" runat="server" Skin="Windows7" Width="400" CssClass="allergy-description" />
            </td>
        </tr>
    </table>
</div>
