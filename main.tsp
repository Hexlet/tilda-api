import "@typespec/http";
import "@typespec/openapi";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

@service(#{
  title: "Tilda API",
})
@server("https://api.tildacdn.info", "Tilda CDN API Server")
@info(#{
  summary: "API для автоматической интеграции проекта на Тильде с собственным сайтом. Все запросы передаются методом GET, ответ в формате JSON. Лимит: 150 запросов в час.",
})
namespace TildaApi;

// ─── Common models ───

model ImageMapping {
  from: string;
  to: string;
}

model JsAsset {
  from: string;
  to: string;
  attrs?: string[];
}

model CssAsset {
  from: string;
  to: string;
}

// ─── Auth query params ───

model AuthParams {
  @query publickey: string;
  @query secretkey: string;
}

// ─── Response wrappers ───

model SuccessResponse<T> {
  status: "FOUND";
  result: T;
}

model ErrorResponse {
  status: "ERROR";
  message?: string;
}

// ─── Project models ───

model ProjectListItem {
  id: string;
  title: string;
  descr: string;
}

model ProjectInfo {
  id: string;
  title: string;
  descr: string;
  customdomain: string;
  export_csspath: string;
  export_jspath: string;
  export_imgpath: string;
  indexpageid: string;
  customcsstext: string;
  favicon: string;
  page404id: string;
  images?: ImageMapping[];
}

// ─── Page models ───

model PageSummary {
  id: string;
  projectid: string;
  title: string;
  descr: string;
  img: string;
  featureimg: string;
  `alias`: string;
  date: string;
  sort: string;
  published: string;
  filename: string;
}

model PageBody {
  ...PageSummary;
  html: string;
  js?: string[];
  css?: string[];
}

model PageFull {
  ...PageSummary;
  html: string;
}

model PageExportBody {
  ...PageSummary;
  html: string;
  images?: ImageMapping[];
  js?: JsAsset[];
  css?: CssAsset[];
}

model PageExportFull {
  ...PageSummary;
  html: string;
  images?: ImageMapping[];
}

// ─── Operations ───

@route("/v1")
interface Projects {
  @route("getprojectslist")
  @get
  getProjectsList(
    ...AuthParams,
  ): SuccessResponse<ProjectListItem[]> | ErrorResponse;

  @route("getprojectinfo")
  @get
  getProjectInfo(
    ...AuthParams,
    @query projectid: string,
  ): SuccessResponse<ProjectInfo> | ErrorResponse;
}

@route("/v1")
interface Pages {
  @route("getpageslist")
  @get
  getPagesList(
    ...AuthParams,
    @query projectid: string,
  ): SuccessResponse<PageSummary[]> | ErrorResponse;

  @route("getpage")
  @get
  getPage(
    ...AuthParams,
    @query pageid: string,
  ): SuccessResponse<PageBody> | ErrorResponse;

  @route("getpagefull")
  @get
  getPageFull(
    ...AuthParams,
    @query pageid: string,
  ): SuccessResponse<PageFull> | ErrorResponse;
}

@route("/v1")
interface Export {
  @route("getpageexport")
  @get
  getPageExport(
    ...AuthParams,
    @query pageid: string,
  ): SuccessResponse<PageExportBody> | ErrorResponse;

  @route("getpagefullexport")
  @get
  getPageFullExport(
    ...AuthParams,
    @query pageid: string,
  ): SuccessResponse<PageExportFull> | ErrorResponse;
}