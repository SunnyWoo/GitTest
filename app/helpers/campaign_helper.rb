module CampaignHelper
  def render_camapign_head
    links = []
    Campaign.all.each do |campaign|
      feature campaign.head_key do
        unless come_from_china?
          links << link_to(campaign.wordings.campaign_head, campaign_path(campaign.key), class: 'header-2')
        end
      end
    end
    links.join.html_safe
  end

  def product_page_asset_url(asset_path)
    "#{ProductIntroPage.find_by('host')}/m/#{asset_path}"
  end

  def render_cart_index_url(args = {})
    path = if feature(:mobile_web_check_out).enable_for_current_session?
             key = args && args.symbolize_keys[:commandp_app].to_b ? 'app_cart_url' : 'mobile_campaign_cart_url'
             SiteSetting.by_key(key)
           end
    path || cart_index_path
  end

  def render_redeem_check_out_link(work_sgid:)
    if feature(:mobile_web_check_out).enable_for_current_session?
      link_to edit_translator('redeem.editor.redeem_button'), mobile_web_check_out_mobile_redeems_path(work_gid: work_sgid), method: :post, class: 'footer-button'
    else
      link_to edit_translator('redeem.editor.redeem_button'), check_out_mobile_redeems_path(sgid: work_sgid), class: 'footer-button'
    end
  end
end
