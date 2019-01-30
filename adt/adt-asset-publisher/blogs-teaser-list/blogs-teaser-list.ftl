<#setting locale=locale>

<#assign page = themeDisplay.getLayout() />
<#assign group_id = page.getGroupId() />
<#assign company_id = themeDisplay.getCompanyId() />

<#assign expandoValueLocalService = serviceLocator.findService("com.liferay.expando.kernel.service.ExpandoValueLocalService") />
<#assign layoutLocalService = serviceLocator.findService("com.liferay.portal.kernel.service.LayoutLocalService")>

<#assign blogsPortletId = "com_liferay_blogs_web_portlet_BlogsPortlet" />
<#assign blogsPagePlid = portalUtil.getPlidFromPortletId(group_id, page.isPrivateLayout(), blogsPortletId) />
<#assign blogsLayout = layoutLocalService.getLayout(blogsPagePlid) />

<#assign blogPageUrl = portalUtil.getLayoutFriendlyURL(blogsLayout, themeDisplay, locale) />

<#assign blogEntryFriendlyUrlPrefix = "/-/blogs/" />


<#if entries?has_content>
  <div class="blogs-teaser-list">
    <#list entries as curBlogEntry>

      <#assign assetRenderer = curBlogEntry.getAssetRenderer() />
      <#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, curBlogEntry) />

      <#if assetLinkBehavior != "showFullContent">
        <#assign viewURL = assetRenderer.getURLViewInContext(renderRequest, renderResponse, viewURL) />
      </#if>

      <#assign viewURL = blogPageUrl + blogEntryFriendlyUrlPrefix + assetRenderer.getUrlTitle() />


      <div class="entry-item">
        <a class="entry-link" href="${viewURL}">
          <div class="entry-date">
            ${dateUtil.getDate(curBlogEntry.getPublishDate(), "yyyy-MM-dd", locale)}
          </div>
          <div class="entry-title">
            ${htmlUtil.escape(curBlogEntry.getTitle())}
          </div>
        </a>
      </div>


    </#list>
  </div>
</#if>
