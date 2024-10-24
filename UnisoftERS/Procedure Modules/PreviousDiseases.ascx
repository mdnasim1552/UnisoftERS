<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PreviousDiseases.ascx.vb" Inherits="UnisoftERS.PreviousDiseases" %>
<style type="text/css">
    .databound-child {
        margin-left: 10px;
    }

    .databound-fieldset {
        width: auto !important;
    }
</style>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(document).ready(function () {

            $('.databound-additional-info').on('focusout', function () {
                var id = $(this).attr('data-uniqueid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                savePreviousDiseases(id, 0, checked, additionalInfoText);
            });

            $('.databound-parent input').on('change', function () {
                var childControl = $(this).closest('td').find('.databound-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.databound-parent').attr('data-uniqueid');
                var checked = $(this).is(':checked');

                savePreviousDiseases(id, 0, checked, '');
            });
        });

        function savePreviousDiseases(previousDiseaseId, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.patientId = parseInt(getCookie('patientId'));
            obj.previousDiseaseId = parseInt(previousDiseaseId);
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/savePreviousDisease",
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

        function childPreviousDisease_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var id = sender.get_attributes().getAttribute('data-uniqueid');

            savePreviousDiseases(id, selectedValue, true, '');
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-sub-header">Diseases</div>
<div class="control-content">
    <asp:Repeater ID="rptPreviousDiseases" runat="server">
        <HeaderTemplate>
            <table class="DataBoundTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
            <td>
                <asp:CheckBox ID="DataBoundCheckbox" runat="server" data-uniqueid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="databound-parent" />
            </td>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Repeater ID="rptAdditionalInfo" runat="server">
        <HeaderTemplate>
            <table class="AdditionalInfoTable" cellpadding="0" cellspacing="0" style="margin-top: 35px;">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
            <td style="vertical-align: top; padding-right: 20px;">
                <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="databound-parent" />:<br />
                <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="databound-additional-info" data-uniqueid='<%# Eval("UniqueId") %>' />
            </td>
        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>
</div>

