<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PlannedProcedures.ascx.vb" Inherits="UnisoftERS.PlannedProcedures" %>
<style type="text/css">
    .PlannedProceduresTable td {
        width: 33.3%;
    }

    .planned-procedure-child {
        margin-left: 10px;
    }

    .planned-procedure-fieldset {
        width: auto !important;
    }
</style>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;


        $(window).on('load', function () {
            ToggleOtherTextbox('planned-procedure');
        });

        $(document).ready(function () {

            $('.planned-procedure-additional-info').on('focusout', function () {
                var id = $(this).attr('data-plannedid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                savePlannedProcedure(id, 0, checked, additionalInfoText);
            });

            $('.planned-procedure-parent input').on('change', function () {
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
                var id = $(this).closest('td').find('.planned-procedure-parent').attr('data-plannedid');
                var checked = $(this).is(':checked');

                savePlannedProcedure(id, 0, checked, '');
            });

            $('.planned-procedure-other-entry-toggle input').on('change', function () {
                checkAndNotifyTextEntry(this, 'planned-procedure');
            });
        });

        function savePlannedProcedure(plannedId, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.indicationId = parseInt(plannedId);
            obj.childId = childId;
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveIndication",
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

        function childPlannedProcedure_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var indicationId = sender.get_attributes().getAttribute('data-plannedid');

            saveIndication(indicationId, selectedValue, true, '');
        }


    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-content">


    <asp:Repeater ID="rptPlannedProcedures" runat="server" OnItemDataBound="rptPlannedProcedures_ItemDataBound">
        <HeaderTemplate>
            <table class="PlannedProceduresTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%--Mahfuz changed on 17 Mar 2021--%>
            <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
            <td>
                <asp:CheckBox ID="PlannedProcedureCheckbox" runat="server" data-plannedid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="planned-procedure-parent" />
            </td>

        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <div class="planned-procedure-other-text-entry other-entry-section">

        <asp:Repeater ID="rptAdditionalInfo" runat="server">
            <HeaderTemplate>
                <table class="AdditionalInfoTable" cellpadding="0" cellspacing="0" style="margin-top: 35px;">
                    <tr>
            </HeaderTemplate>
            <ItemTemplate>
                <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                <td style="vertical-align: top; padding-right: 20px;">
                    <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="planned-procedure-parent" />:<br />
                    <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="planned-procedure-additional-info" data-plannedid='<%# Eval("UniqueId") %>' /><br />
                    <strong class="planned-procedure-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                </td>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</div>
