<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="DICAScoring.ascx.vb" Inherits="UnisoftERS.DICAScoring" %>
<script type="text/javascript">
    $(window).on('load', function () {
        calculateScore();
    });

    function calculateScore() {
        var dicaScoreNotFulfilled = false;

        var points = 0;

        $('.dica-score-dropdown').each(function (idx, itm) {
            var selectedPoints = parseInt($find($(itm)[0].id).get_selectedItem().get_attributes().getAttribute('data-points'));
            var radComboBox = $find($(itm)[0].id);
            var selectedItemElement = radComboBox.get_selectedItem().get_element();
            var hasContent = $(selectedItemElement).text().trim().length > 0;
            if (idx < 2 && !hasContent) dicaScoreNotFulfilled = true;
            points += selectedPoints;
        });
        if (!dicaScoreNotFulfilled) localStorage.clear();
        var scoreTotal = parseInt($('.score-total').text());
        $('.score-total').text(points);
    }
</script>
<telerik:RadNotification ID="RadNotification1" runat="server" />
<fieldset>
    <legend>DICA Score</legend>
    <asp:Repeater ID="rptDICAScore" runat="server">
        <HeaderTemplate>
            <table>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td style="border: none;">
                   <asp:Label ID="lblSectionName" runat="server" Text='<%#Eval("Description") %>' />
                    <asp:HiddenField ID="ParentIdHiddenField" runat="server" Value='<%#Eval("UniqueId") %>' />
                </td>
                <td style="border: none;">
                    <telerik:RadComboBox ID="DICAScoreRadComboBox" OnClientDropDownClosed="calculateScore" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" CssClass="dica-score-dropdown" AppendDataBoundItems="true">
                        <Items>
                            <telerik:RadComboBoxItem Text="" Value="0" />
                        </Items>
                    </telerik:RadComboBox>
                    &nbsp;
                    <%--<asp:RequiredFieldValidator ID="DICARequiredFieldValidator" runat="server" ControlToValidate="DICAScoreRadComboBox" ErrorMessage="*you must choose one" ForeColor="Red" />--%>
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
            <tr>
                <td colspan="2" style="padding-top:5px; font-weight:bold; border:none;">
                    <span>Total score:</span>&nbsp;<span class="score-total">0</span>
                </td>
            </tr>
            </table>
        </FooterTemplate>
    </asp:Repeater>
</fieldset>
