    <%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Complications.ascx.vb" Inherits="UnisoftERS.Complications" %>
<style type="text/css">
    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

    .comorb-child {
        margin-left: 10px;
    }
           .checkboxesTable td {
            padding-right: 10px;
            padding-bottom: 3px;
        }

        .auto-style1 {
            width: 230px;
        }
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            ToggleOtherTextbox('complication');
        });

        $(document).ready(function () {
            $('.complication-additional-info').on('focusout', function () {
                //var comorbId = $(this).attr('data-complicationid'); //mh fixed on 19 Aug 2021 as below 
                var complicationId = $(this).attr('data-complicationid'); 
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');
                  
                saveComplication(complicationId, 0, checked, additionalInfoText);

                
            });

            $('.complication-parent input').on('change', function () {
                var childControl = $(this).closest('td').find('.complication-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                    }
                    else {
                        $(childControl).hide();
                    }
                }

                //auto save
                var id = $(this).closest('td').find('.complication-parent').attr('data-complicationid');
                var checked = $(this).is(':checked');

                saveComplication(id, 0, checked, '');
            });

            $('.complication-other-entry-toggle input').on('change', function () {
                checkAndNotifyTextEntry(this, 'complication');
            });
        });

        function childComplication_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var complicationId = sender.get_attributes().getAttribute('data-complicationid');
                        
            saveComplication(complicationId, selectedValue, true, '');
        }

        function saveComplication(complicationId, childId, checked, additionalInfo) {
            
            var obj = {};
             
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.adverseEventId = parseInt(complicationId);
            obj.childId = childId;
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;

           

            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/saveAdverseEvents",
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
        <asp:Repeater ID="rptComplication" runat="server" OnItemDataBound="rptComplication_ItemDataBound">
            <HeaderTemplate>
                <table class="DataBoundTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                    <tr>
            </HeaderTemplate>
            <ItemTemplate>
                <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                <td>
                    <asp:CheckBox ID="DataCheckbox" runat="server" data-complicationid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="complication-parent" />
                </td>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>

        <div class="complication-other-text-entry other-entry-section">
            <asp:Repeater ID="rptComplicationAdditionalInfo" runat="server">
                <HeaderTemplate>
                    <table class="AdditionalInfoTable" cellpadding="0" cellspacing="0" style="margin-top: 35px;">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                    <td style="vertical-align: top; padding-right: 20px;">
                        <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="complication-parent" />:<br />
                        <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="complication-additional-info" data-complicationid='<%# Eval("UniqueId") %>' /><br />
                        <strong class="complication-free-entry-warning" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
                    </td>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
