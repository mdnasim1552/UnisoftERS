<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="VocalCordParalysis.ascx.vb" Inherits="UnisoftERS.VocalCordParalysis1" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {
            $('.vocal-cord-paralysis-parent input').on('change', function (sender, args) {
                //auto save
                var id = $(this).closest('td').find('.vocal-cord-paralysis-parent').attr('data-uniqueid');
                /*Added by rony tfs-4326*/
                var txtRadioButton = $(this).closest('td').find('.vocal-cord-paralysis-parent').text();
                if (txtRadioButton == "Other") {
                    $('.vocal-cord-other-additional-information').show();
                }
                else {
                    $('.vocal-cord-other-additional-information').hide();
                    $find('<%= AdditionalInformationTextBox.ClientID %>').set_value('');
                }                
                saveVocalCordParalysis(id)
            });
            toggleAdditionalInformation();/*Added by rony tfs-4326*/
        });
        /*Added by rony tfs-4326*/
        function toggleAdditionalInformation() {
            var txtRadioButton = "";
            $('.vocal-cord-paralysis-parent input:radio:checked').each(function () {
                txtRadioButton = $(this).closest('td').find('.vocal-cord-paralysis-parent').text();
            });
            if (txtRadioButton == "Other") {
                 $('.vocal-cord-other-additional-information').show();
             }
             else {
                 $('.vocal-cord-other-additional-information').hide();
             }
        }
        function additionalInformationChanged(sender, args) {
            var valueRadioButton = 0;
            $('.vocal-cord-paralysis-parent input:radio:checked').each(function () {
                valueRadioButton = $(this).closest('td').find('.vocal-cord-paralysis-parent').attr('data-uniqueid')   
            });
            saveVocalCordParalysis(valueRadioButton);
        }
          function paralysisChanged(ctrl) {
            $('.vocal-cord-paralysis-parent input').each(function (idx, itm) {
                if ($(itm)[0].id != ctrl) {
                    $(itm).prop("checked", false);
                }
            });
        }

        function saveVocalCordParalysis(id) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.vocalCordParalysisId = parseInt(id);
            obj.additionalInformation = $find('<%= AdditionalInformationTextBox.ClientID %>').get_value(); /*Added by rony tfs-4326*/
            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveVocalCordParalysis",
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
<div class="control-section-header abnorHeader">Vocal cord functions</div>

<div class="control-content">
    <table>
        <tr>
            <td>Vocal cord</td>
            <td style="vertical-align: top; padding: 0px;">
                <asp:Repeater ID="rptVocalCordParalysis" runat="server">
                    <HeaderTemplate>
                        <table class="DataboundTable" cellpadding="0" cellspacing="0" style="width: 100%;">
                            <tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# IIf(Container.ItemIndex Mod 4 = 0, "</tr><tr>", "")%>
                        <td style="vertical-align: top; width: auto;">
                            <asp:RadioButton ID="DataboundRadioButton" runat="server" data-uniqueid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="vocal-cord-paralysis-parent" GroupName="vocalcordparalysis" />
                        </td>                        
                    </ItemTemplate>
                    <FooterTemplate>
                        </tr>
                </table>
                    </FooterTemplate>
                </asp:Repeater>
            </td>
            <%--Added by rony tfs-4326--%>
            <td colspan="3" style="display:none;" class="vocal-cord-other-additional-information">
                <telerik:RadTextBox ID="AdditionalInformationTextBox" runat="server" Width="199px" ClientEvents-OnValueChanged="additionalInformationChanged"/>
            </td>
        </tr>
    </table>
</div>