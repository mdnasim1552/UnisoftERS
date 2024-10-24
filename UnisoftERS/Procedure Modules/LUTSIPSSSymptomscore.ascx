<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="LUTSIPSSSymptomscore.ascx.vb" Inherits="UnisoftERS.LUTSIPSSSymptomscore" %>
<telerik:RadScriptBlock>
  
     <script type="text/javascript">
         $(document).ready(function () {

             onload();
         });
         function onload() {
             var totalScore = 0;
             var LUTSIPSSScore;
             $("[data-score]").each(function (args) {
                 LUTSIPSSScore = $(this).val().split("-");
                 totalScore = totalScore + parseInt(LUTSIPSSScore[0]);
                 changeDropdownColor(LUTSIPSSScore[0].trim(),this)
               
             })

             changeTotalScoreColor( $("#<%=IPSSTotalScore.ClientID%>").html())
            
         }

         function changeTotalScoreColor(totalScore) {
             let totalScoretext;
           
              if (totalScore == 0) {
                  totalScoretext = ""
                  $("#<%= lblTotalScoreText.ClientID%>").css('color', 'black')
                    $("#<%= IPSSTotalScore.ClientID%>").css('color','black')
              }
              else {
                  $("#<%= lblTotalScoreText.ClientID%>").css('color', 'red')
                   $("#<%= IPSSTotalScore.ClientID%>").css('color','red')
                  
                  if (totalScore >= 1 && totalScore <= 7) {
                      totalScoretext = "<%= sMildText%>";
                  }
                  else {
                          if (totalScore >= 8 && totalScore <= 19) {
                              totalScoretext = "<%= sModeratelyText%>"
                          }
                          else {
                            totalScoretext ="<%= sSeverelyText%>"
                          }

                        }
                 }
             $("#<%= lblTotalScoreText.ClientID%>").html(totalScoretext)
             $("#<%= IPSSTotalScore.ClientID%>").html(totalScore)

         }

         function changeDropdownColor(scorevalue,inputElement){

               if (scorevalue == "0") {

                    inputElement.style.color = "black";
                }
                else {
                    inputElement.style.color = "red";
                }
         }
      function IPSSScore_changed(sender, args) {
          var totalScore = 0;
          var LUTSIPSSScore = args.get_item().get_text().split("-");
          var inputElement = sender.get_inputDomElement();
         
           changeDropdownColor(LUTSIPSSScore[0].trim(),inputElement)

        
          $("[data-score]").each(function (args) {
              LUTSIPSSScore = $(this).val().split("-");
              totalScore = totalScore + parseInt(LUTSIPSSScore[0]);
          })


          changeTotalScoreColor(totalScore)
          var SelectedScoreId = args.get_item().get_value();
          var LUTSIPSSSymptomId = sender.get_attributes().getAttribute('data-LUTSIPSSSymptomid');
          saveLUTSIPSSScore(LUTSIPSSSymptomId, true,SelectedScoreId,totalScore);
      }


         function IPSSScoreQuality_changed(sender, args) {
             var SelectedScoreId = args.get_item().get_value();
            var LUTSIPSSSymptomId = sender.get_attributes().getAttribute('data-LUTSIPSSSymptomid');
            saveLUTSIPSSScore(LUTSIPSSSymptomId, false,SelectedScoreId,0);
         }


            function saveLUTSIPSSScore(LUTSIPSSSymptomId, IsScore, SelectedScoreId,TotalScoreValue) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.LUTSIPSSSymptomId = parseInt(LUTSIPSSSymptomId);
            obj.IsScore  = IsScore;
            obj.SelectedScoreId = SelectedScoreId;
             obj.TotalScoreValue = TotalScoreValue;

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveLUTSIPSSScore",
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
                    $find('<%=IPSSTotalScore.ClientID%>').show();
                }
            });
        }
         </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="False" Title="<div Class='aspxValidationSummaryHeader'>Please correct the following</div>" Skin="Metro"
    Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning"  ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true">

</telerik:RadNotification>
<div class="control-section-header abnorHeader">LUTS/IPSS Symptom Score</div>
<div class="control-content" id ="LUTSIPSSScore">
    <asp:Repeater ID="rptSections" runat="server">
        <ItemTemplate>
            <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />
            </div>
             <asp:Repeater ID="rptLUTSIPSSSymptoms" runat="server" >
                <HeaderTemplate>
                    <table class="IndicationsTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                   
                    <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                    <td>
                        
                         <asp:Label ID="LUTSIPSSSymptomDescription" runat="server" Text='<%#Eval("Description") %>' />
                        </td>
                    <td>
                         <telerik:RadComboBox ID="LUTSIPSSSymptomDropdown"  data-score ="LUTSIPSSSymptomScore" data-LUTSIPSSSymptomid='<%# Eval("UniqueId") %>'  runat="server" Skin="Metro" Width="200" CssClass="followup-text-input" />
                    
                    </td>

                </ItemTemplate>
                <FooterTemplate>
                    </tr>
                   
              </table>
                </FooterTemplate>
            </asp:Repeater>
        </ItemTemplate>
    </asp:Repeater>
       <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
            
       </div>
   <table class="IndicationsTable Fixed700TableWidth">
        <tr> 
            <td></td>
            <td>
            <asp:Label ID="lblIPSSTotalScore1" runat="server" Text='Total Score' />
             <telerik:RadLabel ID="IPSSTotalScore"   Width="50px"  runat="server" style="font-weight:bold"> </telerik:RadLabel>

             <asp:Label ID="lblTotalScoreText" runat="server" Text='' style="font-weight:bold" />
            </td>
        </tr>

   </table>

     <asp:Repeater ID="rptSectionsQuality" runat="server">
        <ItemTemplate>
            <div class="control-sub-header" style="margin-left: 0px; margin-bottom: 5px;">
                <asp:Label ID="SectionNameLabel" runat="server" Text='<%#Eval("SectionName") %>' />
            </div>
             <asp:Repeater ID="rptLUTSIPSSSymptoms" runat="server" >
                <HeaderTemplate>
                    <table class="IndicationsTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                   
                    <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
                    <td>
                        
                         <asp:Label ID="LUTSIPSSSymptomDescription" runat="server" Text='<%#Eval("Description") %>' />
                        </td>
                    <td>
                         <telerik:RadComboBox ID="LUTSIPSSSymptomQualityDropdown"  data-scoreQuality ="LUTSIPSSSymptomScore" data-LUTSIPSSSymptomid='<%# Eval("UniqueId") %>'  runat="server" Skin="Metro" Width="200" CssClass="followup-text-input" />
<%--                        <asp:CheckBox ID="LUTSIPSSSymptomCheckbox" runat="server" data-LUTSIPSSSymptomid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="indications-parent" />--%>
                    
                    </td>

                </ItemTemplate>
                <FooterTemplate>
                    </tr>
                   
              </table>
                </FooterTemplate>
            </asp:Repeater>
        </ItemTemplate>
    </asp:Repeater>

</div>