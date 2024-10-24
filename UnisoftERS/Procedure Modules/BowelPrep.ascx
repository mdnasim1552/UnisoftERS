<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="BowelPrep.ascx.vb" Inherits="UnisoftERS.BowelPrep" %>
<telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <style type="text/css">
        .rltbPager, .rltbToolbar {
            display: none !important;
        }
    </style>
    <script type="text/javascript">
        $(window).on('load', function () {
            toggleOtherTR();
        });

        $(document).ready(function () {
            $('#<%=OtherBowelPrepRadTextBox.ClientID%>').on('focusout', function () {
                PrepChanged();
            });
            $('#<%=OtherEnemaRadTextBox.ClientID%>').on('focusout', function () {
                PrepChanged();
            });
        });

        function bowelprep_changed() {
            
            if ($find('<%=FormationComboBox.ClientID%>').get_text() != '') {
                $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>').set_value(2);
            }

            if ($find('<%=FormationComboBox.ClientID%>').get_text() != '' && $find('<%=FormationComboBox.ClientID%>').get_text().toLowerCase().indexOf('enema') == -1) {
                $('.trEnima').show();
            }
            else {
                $('.trEnima').hide();
                //set combo box to value 0
                $find('<%=EnemaFormationComboBox.ClientID%>').set_value(0);
                $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>').set_value(2);
            }

            toggleOtherTR();
            PrepChanged();
        }

        function enema_changed(sender, args) {
            var prepQty = $('#<%= BowelPrepQtyRadNumericTextBox.ClientID%>').val();

            if (sender.get_text() != "") {
                var defaultVolume = args.get_item().get_attributes().getAttribute('data-defaultvolume');
                $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>').set_value(2 + parseInt(defaultVolume));
            }
            else {
                $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>').set_value(2);
            }

            toggleOtherTR();
            PrepChanged();
        }

        function toggleOtherTR() {
            var selectedOption = $find('<%=FormationComboBox.ClientID%>').get_text().toLowerCase();

            if (selectedOption == '') { // issue 4376
                $('.trEnima').hide();

                $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>').set_value('');
                $find('<%=EnemaFormationComboBox.ClientID%>').set_value(0);
                $find('<%=EnemaFormationComboBox.ClientID%>').clearSelection();

                $('.trScale').hide();

                $find('<%= RightRadNumericTextBox.ClientID%>').clear();
                $find('<%= TransverseRadNumericTextBox.ClientID%>').clear();
                $find('<%= LeftRadNumericTextBox.ClientID%>').clear();
            }
            else {
                $('.trScale').show();

                if ($find('<%=FormationComboBox.ClientID%>').get_text() != '') {
                    $('.trEnima').show();
                }
                else {
                    $('.trEnima').hide();
                    //set combo box to value 0
                    $find('<%=EnemaFormationComboBox.ClientID%>').clearSelection();
                }

                if ($find('<%=FormationComboBox.ClientID%>').get_text().toLowerCase() == 'other') {
                    $('.trOther').show();
                }
                else {
                    $('.trOther').hide();
                    $('#<%=OtherBowelPrepRadTextBox.ClientID%>').val('');
                }

                if ($find('<%=EnemaFormationComboBox.ClientID%>').get_text().toLowerCase() == 'other') {
                    $('.trOtherEnema').show();
                }
                else {
                    $('.trOtherEnema').hide();
                    $('#<%=OtherEnemaRadTextBox.ClientID%>').val('');
                }
            }
        }

        function PrepChanged() {
            var elem_id = $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>');
            var elem_val = $find('<%= BowelPrepQtyRadNumericTextBox.ClientID%>').get_value();
            if (elem_id && parseInt(elem_val) === 0) {
                var oWnd = $find("<%=ConfirmRadWindow.ClientID%>");
                $('#<%= lblMessage.ClientID%>').html('Bowel prep is 0.<br>Would you like to proceed?');
                oWnd.show();
                return;
            } else if (elem_id && elem_val === '') return;
            saveBowelPrepHelper();
        }

        function saveBowelPrepHelper(){
            var prepId = $find('<%=FormationComboBox.ClientID%>').get_value();
            var enemaId = ($find('<%=EnemaFormationComboBox.ClientID%>').get_value() == '') ? 0 : parseInt($find('<%=EnemaFormationComboBox.ClientID%>').get_value());
            var quantity = ($('#<%= BowelPrepQtyRadNumericTextBox.ClientID%>').val() == '') ? 0 : parseFloat($('#<%= BowelPrepQtyRadNumericTextBox.ClientID%>').val());
            var totalScore = 0;//parseInt($('#<%= TotalScoreLabel.ClientID%>').val());
            var rightScore = parseInt($('#<%= RightRadNumericTextBox.ClientID%>').val());
            var transverseScore = parseInt($('#<%= TransverseRadNumericTextBox.ClientID%>').val());
            var leftScore = parseInt($('#<%= LeftRadNumericTextBox.ClientID%>').val());


            if (rightScore != null && rightScore >= 0 && rightScore <= 3) {
                //totalScore += rightScore;
            }
            else {
                rightScore = -1;
            }

            if (transverseScore != null && transverseScore >= 0 && transverseScore <= 3) {
                //totalScore += transverseScore;
            }
            else {
                transverseScore = -1;
            }

            if (leftScore != null && leftScore >= 0 && leftScore <= 3) {
                //totalScore += leftScore;
            }
            else {
                leftScore = -1;
            }

            var txtbox = $('#<%= TotalScoreLabel.ClientID%>');
            if (rightScore == -1 && leftScore == -1 && transverseScore == -1) {
                //set total score to -1 if none are filled in
                totalScore = -1
                txtbox.val('');
            }
            else {
                totalScore = ((rightScore == -1 ? 0 : rightScore) +
                    (leftScore == -1 ? 0 : leftScore) +
                    (transverseScore == -1 ? 0 : transverseScore));
                txtbox.val(totalScore);
            }

            //set text box to empty if no scores are filled in

            saveBowelPrep(prepId, leftScore, rightScore, transverseScore, enemaId, quantity, totalScore);
        }

        function saveBowelPrep(prepId, leftScore, rightScore, transverseScore, enemaId, quantity, totalScore) {

            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.bowelPrepId = parseInt(prepId);
            obj.quantity = parseInt(quantity);
            obj.leftScore = parseInt(leftScore);
            obj.rightScore = parseInt(rightScore);
            obj.transverseScore = parseInt(transverseScore);
            obj.totalScore = parseInt(totalScore);
            obj.additionalInfo = ($('#<%=OtherBowelPrepRadTextBox.ClientID%>').length == 0) ? '' : $('#<%=OtherBowelPrepRadTextBox.ClientID%>').val();
            obj.enemaId = parseInt(enemaId);
            obj.enemaOther = ($('#<%=OtherEnemaRadTextBox.ClientID%>').length == 0) ? '' : $('#<%=OtherEnemaRadTextBox.ClientID%>').val();

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureBowelPrep",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                    //check if a new item was added and add that to the list. can we rebind it from here...?
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

        function displayScaleGuidelines() {
            $find('<%=ScaleGuideRadLightBox.ClientID%>').show();
            return false;
        }

        function closeConfirmRadWindow(sender, args) {
            if (sender.get_element().id.indexOf('CancelRadButton') !== -1) {
                $find('<%=BowelPrepQtyRadNumericTextBox.ClientID%>').focus();
                $find('<%=BowelPrepQtyRadNumericTextBox.ClientID%>').set_value('');
            } else if (sender.get_element().id.indexOf('ContinueRadButton') !== -1) {
                saveBowelPrepHelper();
            }
            var window = $find('<%=ConfirmRadWindow.ClientID%>');
            window.close();
        }
    </script>

</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-sub-header" id="BowelPrepLabel" runat="server">Bowel prep</div>
<div class="control-content">
    <table>
        <tr>
            <td>Bowel prep formulation</td>
            <td>
                <telerik:RadComboBox ID="FormationComboBox" Text="Formation:" runat="server" Width="200" Skin="Metro" AutoPostBack="false" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="bowelprep_changed" AppendDataBoundItems="true">
                    <Items>
                        <telerik:RadComboBoxItem Value="0" Text="" />
                    </Items>
                </telerik:RadComboBox>
                &nbsp; 
                <span>Sachets</span>
                <telerik:RadNumericTextBox ID="BowelPrepQtyRadNumericTextBox" runat="server" Skin="Windows7" Width="75" MinValue="0" NumberFormat-GroupSeparator="" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="PrepChanged" />
            </td>
        </tr>
        <tr class="trOther" style="display: none;">
            <td>specify other</td>
            <td>
                <telerik:RadTextBox ID="OtherBowelPrepRadTextBox" runat="server" /></td>
        </tr>
        <tr class="trEnima" style="display: none;">
            <td>Enema formulation</td>
            <td>
                <telerik:RadComboBox ID="EnemaFormationComboBox" Text="Formation:" runat="server" Width="200" Skin="Metro" AutoPostBack="false" OnClientSelectedIndexChanged="enema_changed" AppendDataBoundItems="true">
                    <Items>
                        <telerik:RadComboBoxItem Text="" Value="0" />
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
        <tr class="trOtherEnema" style="display: none;">
            <td>specify other</td>
            <td>
                <telerik:RadTextBox ID="OtherEnemaRadTextBox" runat="server" /></td>
        </tr>
        <tr class="trScale">
            <td align="left" colspan="2" style="padding-top: 15px; font-style: italic; text-align: left;">Preparation Scale&nbsp;<small><asp:LinkButton ID="ViewScaleLinkButton" runat="server" Text="scale guidelines" OnClientClick="return displayScaleGuidelines()" /></small>
            </td>
        </tr>

        <tr class="trScale">
            <td colspan="2" style="padding: 0px; width: auto;">
                 Left &nbsp;<telerik:RadNumericTextBox ID="LeftRadNumericTextBox" EmptyMessage="Not examined" runat="server" Skin="Office2007" Width="105" MinValue="0" MaxValue="3" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="PrepChanged" />
               
                Transverse &nbsp;<telerik:RadNumericTextBox ID="TransverseRadNumericTextBox" EmptyMessage="Not examined" runat="server" Skin="Windows7" Width="105" MinValue="0" MaxValue="3" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="PrepChanged" />
                
                Right &nbsp;<telerik:RadNumericTextBox ID="RightRadNumericTextBox" EmptyMessage="Not examined" runat="server" Skin="Office2007" Width="105" MinValue="0" MaxValue="3" NumberFormat-DecimalDigits="0" ClientEvents-OnValueChanged="PrepChanged" />

               
                
                &nbsp;&nbsp; 
                
                Total Score:&nbsp;<asp:TextBox ID="TotalScoreLabel" runat="server" Width="60" Enabled="false" />
            </td>
        </tr>
    </table>
    <telerik:RadLightBox ID="ScaleGuideRadLightBox" runat="server" Modal="true" CurrentItemIndex="0" ZIndex="999999">
        <Items>
            <telerik:RadLightBoxItem ImageUrl="../Images/bowel_prep_scale_guide.jpg" />
        </Items>
    </telerik:RadLightBox>
    <telerik:RadWindowManager ID="RadWindowManager3" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="ConfirmRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Height="210px" Width="400px" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Bowel Prep" BackColor="#ffffcc" Left="100px">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td style="vertical-align: top; padding-left: 20px; padding-top: 40px">
                                <img id="Img1" runat="server" src="~/Images/info-32x32.png" alt="icon" />
                            </td>
                            <td style="text-align: center; padding: 20px;">
                                <asp:Label ID="lblMessage" runat="server" Font-Size="Large" Text="Bowel prep 0" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="padding: 10px; text-align: center; padding-top: 30px !important;">
                                <telerik:RadButton ID="ContinueRadButton" runat="server" Text="Continue" Skin="Windows7" ButtonType="SkinnedButton" Font-Size="Large" AutoPostBack="false" Style="margin-right: 20px;" OnClientClicked="closeConfirmRadWindow" />
                                <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeConfirmRadWindow" Font-Size="Large" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>
</div>

