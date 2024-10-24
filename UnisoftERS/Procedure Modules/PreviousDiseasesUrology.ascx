<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PreviousDiseasesUrology.ascx.vb" Inherits="UnisoftERS.PreviousDiseasesUrology" %>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />


<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        
        function childPreviousDiseaseUrology_dropdown_changed(sender, args) {
        
            var childId = args.get_item().get_value();
            var PreviousDiseaseId = sender.get_attributes().getAttribute('data-PreviousDiseaseId');
            SavePreviousDiseaseUrology(PreviousDiseaseId, true, '', childId);
        }


        function SavePreviousDiseaseUrology(previousDiseaseId, checked, additionalInfo, childId) {
           
            var obj = {};
            obj.procedureId = parseInt("<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID) %>");
            obj.previousDiseaseId = previousDiseaseId;
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;
            obj.childId = childId;
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/savePreviousDiseaseUrology",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    
                  
                    //show a message
                    var objError = x.responseJSON;
                    
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        };

        $(document).ready(function () {
            $(".previousDiseaseUrology-parent input").on('change', function () {
                var id = $(this).closest('td').find('.previousDiseaseUrology-parent').attr('data-PreviousDiseaseId');

                var checked = $(this).is(':checked');
                
               
                SavePreviousDiseaseUrology(id, checked, '', 0);
              
                if (checked) {
                    $(this).closest("td").find(".previousDiseaseUrology-child").show();
                }
                else {
                    $(this).closest("td").find(".previousDiseaseUrology-child").hide();
                }
            });

            $('.databound-additional-info-urology').on('focusout', function () {
                var id = $(this).attr('data-PreviousDiseaseId');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');
                SavePreviousDiseaseUrology(id, true, additionalInfoText,0);
            });


              $(".previousDiseaseUrology-child-chkbox input").on('change', function () {
                var parenPreviousDiseaseId = $(this).closest('td').find('.previousDiseaseUrology-parent').attr('data-PreviousDiseaseId');
                let childPreviousDiseaseId = 0;
                

               if ($(this).is(':checked'))
                    childPreviousDiseaseId = $(this).closest('td').find('.previousDiseaseUrology-child-chkbox').attr('data-PreviousDiseaseId');

                 SavePreviousDiseaseUrology(parenPreviousDiseaseId, true, '', childPreviousDiseaseId);
              })
        });

    </script>
</telerik:RadScriptBlock>
<div class="control-section-header abnorHeader">Past Urological History</div>
<div class="control-content">
    <asp:Repeater ID="rptSection" runat="server">
        <HeaderTemplate>
            <table cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 3 = 0, "</tr><tr>", "")%>
            <td  style="vertical-align:top; width:300px">
                <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                    <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />

                </div>
                <asp:Repeater ID="rptPreviousDiesease" runat="server">
                    <HeaderTemplate>
                        <table>
                    </HeaderTemplate>
                    <ItemTemplate>

                        <tr>
                            <td>
                                <asp:CheckBox ID="PreviousDiseaseCheckbox" runat="server" data-PreviousDiseaseId='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="previousDiseaseUrology-parent" />

                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                <asp:Repeater ID="rptAdditionalInfo" runat="server">
                    <HeaderTemplate>
                        <table class="IndicationsTable MinTableWidth300" cellpadding="0" cellspacing="0">
                    </HeaderTemplate>
                    <ItemTemplate>

                        <tr>
                            <td>
                                <telerik:RadTextBox ID="txtUrologyAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="databound-additional-info-urology" data-PreviousDiseaseId='<%# Eval("UniqueId") %>' />


                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </td>
        </ItemTemplate>
        <FooterTemplate>
            </tr></table>  
        </FooterTemplate>
    </asp:Repeater>


</div>
