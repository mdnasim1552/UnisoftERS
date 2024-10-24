<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="SedationScore.ascx.vb" Inherits="UnisoftERS.SedationScore" %>
<telerik:RadScriptBlock runat="server">
    <style type="text/css">
        .sedation-score-child {
            margin-left: 10px;
        }
    </style>
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {
            $('.sedation-score-parent input').on('change', function (sender, args) {
                var childControl = $(this).closest('td').find('.sedation-score-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                        $(childControl).css('display', 'inline-block');
                    }
                    else {
                        $(childControl).hide();
                    }
                }
                else {
                    $('.sedation-score-child').hide();
                }

                //auto save
                var id = $(this).closest('td').find('.sedation-score-parent').attr('data-uniqueid');

                saveSedationScore(id, 0);
            });
            /*Added by rony tfs-4075*/
            if ($('#GeneralAnaestheticChkBox').is(':checked')) {
                $(".patient-sedation-aneathetic").show();
                $(".general-aneathetic-mandatory-remove").hide(); 
            }
            $("#GeneralAnaestheticChkBox").click(function () {
                if ($("#GeneralAnaestheticChkBox").is(':checked')) {
                    $(".patient-sedation-aneathetic").show();
                    $(".general-aneathetic-mandatory-remove").hide();                    
                } else {
                    $(".patient-sedation-aneathetic").hide();
                    $(".general-aneathetic-mandatory-remove").show();   
                }
                var numericGeneralAneathetic = $find("<%= PatientSedationGeneralAneatheticTextBox.ClientID %>");
                numericGeneralAneathetic.clear();
                patientSedationAutoSave(); 
            });
        });
        /*Added by rony tfs-4075*/
        function GeneralAneatheticOnChange(sender, args) {
            patientSedationAutoSave();            
        }
        function patientSedationAutoSave() {  
            var idRadioButton = 0;
            var idDropdown = 0;
            $('.sedation-score-parent input:radio:checked').each(function () {
                idRadioButton = $(this).closest('td').find('.sedation-score-parent').attr('data-uniqueid')                
            });
            var injectionTypeBoxes = document.getElementsByClassName("sedation-score-child");
            for (var i = 0; i < injectionTypeBoxes.length; i++) {
                var comboBox = $find(injectionTypeBoxes[i].id);
                idDropdown = comboBox.get_selectedItem().get_value();
            }           
            saveSedationScore(idRadioButton, idDropdown)
        }
        function sedationScoreChanged(ctrl) {
            $('.sedation-score-parent input').each(function (idx, itm) {
                if ($(itm)[0].id != ctrl) {
                    $(itm).prop("checked", false);
                }
            });
        }

        function childsedationscore_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var scoreId = sender.get_attributes().getAttribute('data-uniqueid');

            saveSedationScore(scoreId, selectedValue);
        }

        function saveSedationScore(scoreId, childId) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.sedationScoreId = parseInt(scoreId);
            obj.childId = childId;
            obj.generalAneathetic = $find('<%=PatientSedationGeneralAneatheticTextBox.ClientID%>').get_value() == '' ? 0 : $find("<%= PatientSedationGeneralAneatheticTextBox.ClientID %>").get_value(); /*Added by rony tfs-4075*/

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveSedationScore",
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
    <table>
        <tr>
            <td>Patient sedation</td>
            <td style="vertical-align:top; padding:0px;">
                <asp:Repeater ID="rptSedationScore" runat="server">
                    <HeaderTemplate>
                        <table class="DataboundTable" cellpadding="0" cellspacing="0" style="width:100%;">
                            <tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# IIf(Container.ItemIndex Mod 3 = 0, "</tr><tr>", "")%>
                        <td style="vertical-align: top; width:auto;">
                            <asp:RadioButton ID="DataboundRadioButton" runat="server" data-uniqueid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="sedation-score-parent" GroupName="sedationscore" />
                        </td>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tr>
                </table>
                    </FooterTemplate>
                </asp:Repeater>
            </td>
        </tr>
        <%--Added by rony tfs-4075--%>
        <tr style="display:none;" class="patient-sedation-aneathetic"> 
            <td>
                <asp:Label runat="server" ID="Label1" Text="General Aneathetic" />
            </td>
            <td>
                <telerik:RadNumericTextBox ID="PatientSedationGeneralAneatheticTextBox" runat="server"
                    Width="50px"
                    MinValue="0">
                    <ClientEvents OnValueChanged="GeneralAneatheticOnChange" />
                    <NumberFormat DecimalDigits="2" AllowRounding="false" />
                </telerik:RadNumericTextBox>
                <asp:Label runat="server" ID="Label2" Text="%" />
            </td>
        </tr>
    </table>
</div>