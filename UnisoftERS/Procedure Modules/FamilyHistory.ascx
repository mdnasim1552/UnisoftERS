<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="FamilyHistory.ascx.vb" Inherits="UnisoftERS.FamilyHistory" %>
<style type="text/css">
    .DataBoundTable td {
        vertical-align: top;
    }
</style>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;


        $(window).on('load', function () {

        });

        $(document).ready(function () {
            $(".family-history-none").change(function () {
                if ($(".family-history-none input").is(':checked')) {
                    $(".family-history-parent input:checked").not('.family-history-none input').each(function (idx, itm) {
                        var id = $(this).closest('span').attr('data-uniqueid');
                        $(this).prop('checked', false);
                        savePatientFamilyHistory(id, 0, false, '');
                    });
                }
            });

            $('.family-history-additional-info').on('focusout', function () {
                var id = $(this).attr('data-uniqueid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                savePatientFamilyHistory(id, 0, checked, additionalInfoText);
            });

            $('.family-history-parent input').on('change', function () {
                var childControl = $(this).closest('td').find('.planned-procedure-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.family-history-parent').attr('data-uniqueid');
                var checked = $(this).is(':checked');

                savePatientFamilyHistory(id, 0, checked, '');
                
                //untick none
                if ($(this).closest('span').text().toLowerCase() != 'no risk' && checked) {
                    $(".family-history-none input").prop('checked', false);
                    var noneID = $(".family-history-none").attr('data-uniqueid');
                    savePatientFamilyHistory(noneID, 0, false, '');
                }

            });
        });

        function savePatientFamilyHistory(id, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.patientId = parseInt(getCookie('patientId'));
            obj.familyDiseaseId = parseInt(id);
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveFamilyHistory",
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

        function patientFamilyHistory_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var indicationId = sender.get_attributes().getAttribute('data-uniqueid');

            saveIndication(indicationId, selectedValue, true, '');
        }

    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="abnorHeader">Family History</div>
<div id="FamilyHistoryDiv" runat="server" class="control-content">
    <div class="info">
        <asp:Label ID="SaveErrorMessageLabel" runat="server" Text="There was a problem saving your data. Please save manually or contact support for help" ForeColor="Red" Style="display: none;" />
    </div>
    <div>
        <asp:Repeater ID="rptFamilyHistory" runat="server">
            <HeaderTemplate>
                <table class="DataBoundTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                    <tr>
            </HeaderTemplate>
            <ItemTemplate>
                <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                <td>
                    <asp:CheckBox ID="DataBoundCheckbox" runat="server" data-uniqueid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="family-history-parent" />
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
                    <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="family-history-parent" />:<br />
                    <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="family-history-additional-info" data-uniqueid='<%# Eval("UniqueId") %>' />
                </td>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>
