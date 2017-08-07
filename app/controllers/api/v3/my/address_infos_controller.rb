=begin
@apiDefine AddressInfoResponse
@apiSuccessExample {json} Response-Example:
{
  "address_info": {
    "id": 228,
    "address": "Yes Jedi Road",
    "city": "Taipei",
    "name": "jedi palace",
    "phone": "0955666777",
    "state": null,
    "zip_code": null,
    "country": "Taiwan",
    "created_at": "2016-01-30T13:10:48.941+08:00",
    "updated_at": "2016-01-30T13:10:48.941+08:00",
    "country_code": "TW",
    "shipping_way": "standard",
    "email": "jedi.noel@commandp.com",
    "address_name": "哼哼",
    "province": {
      "id": "1",
      "name": "上海市"
    }
  }
}
=end
class Api::V3::My::AddressInfosController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_address_info, only: %w(update destroy show)

=begin
@api {get} /api/my/address_infos Get the current_user's address_infos list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/AddressInfos
@apiName UserAddressInfos
@apiParamExample {json} Response-Example:
 {
   "address_infos": [
     {
                   "id": 1,
         "address_name": "Address Name-1",
                 "name": "Ms. Golda Reilly",
              "address": "06178 Johns OvalApt. 766",
                 "city": "North Lauriane",
             "zip_code": "22515",
                "phone": "593.647.0658",
                "state": "Louisiana",
              "country": "United States",
                "email": "Wahaha@commandp.com",
                "province": {
                  "id": "1",
                  "name": "上海市"
                }
     }
   ],
   "meta": {
     "address_count": 1
   }
 }
=end
  def index
    @address_infos = BillingProfileDecorator.decorate_collection(current_user.address_infos)
    render 'api/v3/address_infos/index'
  end

=begin
@api {post} /api/my/address_infos Create current_user's address_info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/AddressInfos
@apiName CreateUserAddressInfo
@apiParam {String} name address receiptor name
@apiParam {String} [address_name] address_nickname
@apiParam {String} address address
@apiParam {String} city city
@apiParam {String} phone address receiptor phone number
@apiParam {String} email address reciptor email
@apiParam {String} country_code country code e.g. 'TW', 'US'
@apiParam {String} [state] state or region
@apiParam {String} [zip_code] zip code
@apiUse AddressInfoResponse
=end
  def create
    @address_info = current_user.address_infos.new
    form = BillingProfileForm.new(@address_info)
    form.attributes = permitted_address_info_parmas
    form.save!
    render 'api/v3/address_infos/show'
  end

=begin
@api {put} /api/my/address_infos/:id Update specific address_info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/AddressInfos
@apiName UpdateSpecificAddress_info
@apiParam {Integer} id address_info id
@apiParam {String} [name] address receiptor name
@apiParam {String} [address_name] address_nickname
@apiParam {String} [address] address
@apiParam {String} [city] city
@apiParam {String} [phone] address receiptor phone number
@apiParam {String} [email] address reciptor email
@apiParam {String} [country_code] country code e.g. 'TW', 'US'
@apiParam {String} [state] state or region
@apiParam {Integer} [province_id] province
@apiParam {String} [zip_code] zip code
@apiUse AddressInfoResponse
=end
  def update
    form = BillingProfileForm.new(@address_info)
    form.attributes = permitted_address_info_parmas
    form.save!
    render 'api/v3/address_infos/show'
  end

=begin
@api {get} /api/my/address_infos/:id Get the specific address_info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/AddressInfos
@apiName GetSpecificAddress_info
@apiParam {Integer} id address_info id
@apiUse AddressInfoResponse
=end
  def show
    render 'api/v3/address_infos/show'
  end

=begin
@api {delete} /api/my/address_infos/:id Delete the specific address_info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/AddressInfos
@apiName DeleteSpecificAddress_info
@apiParam {Integer} id address_info id
@apiUse AddressInfoResponse
=end
  def destroy
    current_user.address_infos.destroy @address_info
    render 'api/v3/address_infos/show'
  end

  private

  def permitted_address_info_parmas
    params.permit(:name,
                  :address_name,
                  :address,
                  :city,
                  :state,
                  :province,
                  :dist,
                  :dist_code,
                  :phone,
                  :zip_code,
                  :country_code,
                  :email
                 )
  end

  def find_address_info
    @address_info = current_user.address_infos.find(params[:id])
  end
end
