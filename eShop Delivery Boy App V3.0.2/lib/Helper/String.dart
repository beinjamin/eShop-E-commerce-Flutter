import 'package:deliveryboy/Helper/Constant.dart';

final Uri getUserLoginApi = Uri.parse(baseUrl + 'login');
final Uri getVerifyUserApi = Uri.parse(baseUrl + 'verify_user');
final Uri getFundTransferApi = Uri.parse(baseUrl + 'get_fund_transfers');
final Uri getNotificationApi = Uri.parse(baseUrl + 'get_notifications');
final Uri updateFcmApi = Uri.parse(baseUrl + 'update_fcm');
final Uri getBoyDetailApi = Uri.parse(baseUrl + 'get_delivery_boy_details');
final Uri getUpdateUserApi = Uri.parse(baseUrl + 'update_user');
final Uri getSettingApi = Uri.parse(baseUrl + 'get_settings');
final Uri getOrdersApi = Uri.parse(baseUrl + 'get_orders');
final Uri getResetPassApi = Uri.parse(baseUrl + 'reset_password');
final Uri updateOrderApi = Uri.parse(baseUrl + 'update_order_status');
final Uri updateOrderItemApi = Uri.parse(baseUrl + 'update_order_item_status');

final Uri sendWithReqApi = Uri.parse(baseUrl + 'send_withdrawal_request');
final Uri getWithReqApi = Uri.parse(baseUrl + 'get_withdrawal_request');
final Uri getCashCollection =
    Uri.parse(baseUrl + 'get_delivery_boy_cash_collection');

const String USERNAME = 'username';
const String ADDRESS = 'address';
const String EMAIL = 'email';
const String MOBILE = 'mobile';
const String ID = 'id';
const String PASSWORD = 'password';
const String COUNTRY_CODE = 'country_code';
const String USER_ID = 'user_id';
const String TITLE = 'title';
const String MESSAGE = 'message';
const String REMARK = 'remarks';
const String ALL = 'all';
const String awaitingPayment = 'Awaiting Payment';

const String DATE = 'date_created';
const String DATE_DEL = 'date';
const String DATE_SEND = 'date_sent';
const String TYPE = 'type';
const String TYPE_ID = 'type_id';
const String IMAGE = 'image';
const String LIMIT = 'limit';
const String OFFSET = 'offset';
const String FCM_ID = 'fcm_id';
const String BALANCE = 'balance';
const String BONUS = 'bonus';
const String NEWPASS = 'new';
const String OLDPASS = 'old';
const String AMT = 'amount';
const String OPNBAL = 'opening_balance';
const String CLSBAL = 'closing_balance';
const String MSG = 'message';
const String STATUS = 'status';
const String DEL_BOY_ID = 'delivery_boy_id';

const String PRIVACY_POLLICY = 'delivery_boy_privacy_policy';
const String TERM_COND = 'delivery_boy_terms_conditions';
const String ORDER_ITEMS = 'order_items';
const String DEL_CHARGE = 'delivery_charge';
const String DELIVERY_TIME = 'delivery_time';
const String DELIVERY_DATE = 'delivery_date';
const String QUANTITY = "quantity";
const String PROMO_DIS = 'promo_discount';
const String WAL_BAL = 'wallet_balance';
const String ORDER_DETAILS = 'order_details';
const String ATTACHMENT = 'attachment';
const String BANK_STATUS = 'banktransfer_status';

const String IMGS = 'images[]';
const String NAME = 'name';
const String SUBTITLE = 'subtitle';
const String TAX = 'tax';
const String SLUG = 'slug';

const String PRODUCT_DETAIL = 'product_details';
const String DESC = 'description';
const String CATID = 'category_id';
const String CAT_NAME = 'category_name';
const String OTHER_IMAGE = 'other_images_md';
const String PRODUCT_VARIENT = 'variants';
const String PRODUCT_ID = 'product_id';
const String PRICE = 'price';
const String MEASUREMENT = 'measurement';
const String MEAS_UNIT_ID = 'measurement_unit_id';
const String SERVE_FOR = 'serve_for';
const String SHORT_CODE = 'short_code';
const String STOCK = 'stock';
const String STOCK_UNIT_ID = 'stock_unit_id';
const String DIS_PRICE = 'special_price';
const String CURRENCY = 'currency';
const String SUB_ID = 'subcategory_id';
const String SORT = 'sort';
const String PSORT = 'p_sort';

const String PORDER = 'p_order';
const String DEL_CHARGES = 'delivery_charges';
const String FREE_AMT = 'minimum_free_delivery_order_amount';

const String CONTACT_US = 'contact_us';
const String ABOUT_US = 'about_us';
const String BANNER = 'banner';
const String CAT_FILTER = 'has_child_or_item';
const String PRODUCT_FILTER = 'has_empty_products';
const String RATING = 'rating';
const String IDS = 'ids';
const String VALUE = 'value';
const String ATTRIBUTES = 'attributes';
const String ATTRIBUTE_VALUE_ID = 'attribute_value_ids';
const String IMAGES = 'images';
const String NO_OF_RATE = 'no_of_ratings';
const String ATTR_NAME = 'attr_name';
const String VARIENT_VALUE = 'variant_values';
const String COMMENT = 'comment';

const String SEARCH = 'search';
const String PAYMENT_METHOD = 'payment_method';
const String ISWALLETBALUSED = "is_wallet_used";
const String WALLET_BAL_USED = 'wallet_balance_used';
const String USERDATA = 'user_data';
const String DATE_ADDED = 'date_added';

const String TOP_RETAED = 'top_rated_product';

const String USER_NAME = 'user_name';

const String CITY = 'city';
const String DOB = 'dob';
const String AREA = 'area';

const String STREET = 'street';
const String PINCODE = 'pincode';

const String LATITUDE = 'latitude';
const String LONGITUDE = 'longitude';

const String FAV = 'is_favorite';
const String ISRETURNABLE = 'is_returnable';
const String ISCANCLEABLE = 'is_cancelable';
const String ISPURCHASED = 'is_purchased';
const String ISOUTOFSTOCK = 'out_of_stock';
const String PRODUCT_VARIENT_ID = 'product_variant_id';
const String QTY = 'qty';
const String CART_COUNT = 'cart_count';

const String SUB_TOTAL = 'sub_total';
const String TAX_AMT = 'tax_amount';
const String TAX_PER = 'tax_percentage';
const String CANCLE_TILL = 'cancelable_till';
const String ALT_MOBNO = 'alternate_mobile';
const String STATE = 'state';
const String COUNTRY = 'country';
const String ISDEFAULT = 'is_default';
const String LANDMARK = 'landmark';
const String CITY_ID = 'city_id';
const String AREA_ID = 'area_id';
const String HOME = 'Home';
const String OFFICE = 'Office';
const String OTHER = 'Other';
const String FINAL_TOTAL = 'final_total';
const String PROMOCODE = 'promo_code';
const String DELIVERY_CHARGE = 'delivery_charge';
const String ATTACHMENTS = 'attachments';

const String MOBILENO = 'mobile_no';

const String TOTAL = 'total';
const String TOTAL_PAYABLE = 'total_payable';

const String TOTAL_TAX_PER = 'total_tax_percent';
const String TOTAL_TAX_AMT = 'total_tax_amount';
const String PRODUCT_LIMIT = "p_limit";
const String PRODUCT_OFFSET = "p_offset";
const String SEC_ID = 'section_id';

const String ATTR_VALUE = 'attr_value_ids';

const String ORDER_ID = 'order_id';
const String IS_SIMILAR = 'is_similar_products';
const String PLACED = 'received';
const String SHIPED = 'shipped';
const String PROCESSED = 'processed';
const String DELIVERD = 'delivered';
const String CANCLED = 'cancelled';
const String RETURNED = 'returned';
const String ITEM_RETURN = 'Item Return';
const String ITEM_CANCEL = 'Item Cancel';
const String CASH_RECEIVED = 'cash_received';
const String TRANS_DATE = 'transaction_date';

const String ADD_ID = 'address_id';
const String STYLE = 'style';
const String ORDERITEMID = 'order_item_id';
const String ORDERID = 'order_id';
const String OTP = "otp";
const String DELIVERY_BOY_ID = 'delivery_boy_id';
const String ISALRCANCLE = 'is_already_cancelled';
const String ISALRRETURN = 'is_already_returned';
const String ISRTNREQSUBMITTED = 'return_request_submitted';
const String OVERALL = 'overall_amount';
const String AVAILABILITY = 'availability';
const String MADEIN = 'made_in';
const String INDICATOR = 'indicator';
const String STOCKTYPE = 'stock_type';
const String SAVE_LATER = 'is_saved_for_later';
const String ATT_VAL = 'attribute_values';
const String ATT_VAL_ID = 'attribute_values_id';
const String FILTERS = 'filters';
const String TOTALALOOW = 'total_allowed_quantity';
const String KEY = 'key';
const String AMOUNT = 'amount';
const String PAYMENT_ADD = 'payment_address';
const String ORDER_BY = "order";
const String DELIVERY_BOY_CASH = "delivery_boy_cash";
const String DELIVERY_BOY_CASH_COLL = "delivery_boy_cash_collection";

const String CONTACT = 'contact';
const String TXNID = 'txn_id';
const String SUCCESS = 'Success';
const String ACTIVE_STATUS = 'active_status';
const String WAITING = 'awaiting';
const String DEL_DATE = 'delivery_date';
const String DEL_TIME = 'delivery_time';

final String isLogin = '$appName+_islogin';
String? CUR_USERID = '';
String? CUR_USERNAME = "";
String CUR_BALANCE = "0.0";
String? CUR_BONUS = ' ';
String? CUR_CURRENCY = ' ';
String? SUPPORTED_LOCALES;

late double deviceHeight;
double? deviceWidth;
