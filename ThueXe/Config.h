//
//  Config.h
//  ThueXe
//
//  Created by VMio69 on 10/1/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#ifndef Config_h
#define Config_h
#import "AFNetworking.h"
//api
#define URL_SERVER @"http://thuexevn.com"
#define API_GET_LIST_ONLINE [NSString stringWithFormat:@"%@/Api/getlistonline",URL_SERVER] // dùng cho hành khách
#define API_REGISTER [NSString stringWithFormat:@"%@/Api/register",URL_SERVER]
#define API_LOCATE [NSString stringWithFormat:@"%@/Api/locate",URL_SERVER]
#define API_GET_AROUND [NSString stringWithFormat:@"%@/Api/getaround",URL_SERVER] // dùng cho lái xe
#define API_GET_MADE_LIST [NSString stringWithFormat:@"%@/Api/getCarMadeList",URL_SERVER]
#define API_GET_MODEL_LIST [NSString stringWithFormat:@"%@/Api/getCarModelList",URL_SERVER]

#define WIDTH_SCREEN [UIScreen mainScreen].bounds.size.width
#define HEIGHT_SCREEN [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(int, USER_TYPE){
    USER_TYPE_PASSENGER,
    USER_TYPE_DRIVER
};

typedef NS_ENUM(int, TEXT_FIELD){
    TEXT_FIELD_CAR_MADE,
    TEXT_FIELD_CAR_MODEL,
    TEXT_FIELD_CAR_TYPE,
    TEXT_FIELD_CAR_SIZE,
    TEXT_FIELD_CAR_YEAR,
    TEXT_FIELD_CAR_PRICE
};

typedef NS_ENUM(int, CAR_STATUS){
    CAR_STATUS_ENABLE,
    CAR_STATUS_DISABLE
};

#define CAR_MADE_MODEL @[@{@"car_made":@"Audi",\
                        @"car_model":@[@"Audi A3",@"Audi A4",@"Audi A5",@"Audi A6",@"Audi A7",@"Audi A8L 3.0",@"Audi A8L 4.0",@"Audi TT",@"Audi Q1",@"Audi Q3",@"Audi Q5",@"Audi Q7 2.0",@"Audi Q7 3.0"]},\
                    @{@"car_made":@"BMW",\
                        @"car_model":@[@"BMW 118i",@"BMW 218i Active Tourer",@"BMW 218i Gran Tourer",@"BMW M2",@"BMW 320i",@"BMW 330i",@"BMW 320i GT",@"BMW 328i GT",@"BMW M3",@"BMW 420i",@"BMW 420i Cabriolet",@"BMW 428i Grand Coupé",@"BMW M4 Coupé",@"BMW M4 Cabriolet",@"BMW 520i",@"BMW 528i",@"BMW 528i GT",@"BMW 535i",@"BMW 640i Grand Coupé",@"BMW 730Li",@"BMW 740Li",@"BMW 750Li",@"BMW X1 sDrive 18i",@"BMW X1 sDrive 20i",@"BMW X3 xDrive 20i",@"BMW X3 xDrive 28i",@"BMW X4 xDrive 28i",@"BMW X5 xDrive 30i",@"BMW X5 xDrive 35i",@"BMW X6 xDrive 35i",@"BMW X6 xDrive 30d",@"BMW Z4 sDrive 20i"]},\
                    @{@"car_made":@"Chevrolet",\
                        @"car_model":@[@"Aveo LT",@"Aveo LTZ",@"Spark Dou (van)",@"Spark Dou LS",@"Spark Dou LT",@"Orlando LTZ",@"Cruze LT",@"Cruze LTZ",@"Captiva LTZ",@"Colorado LT 4x2",@"Colorado LT 4x4",@"Colorado LTZ",@"Colorado Hight Country"]},\
                    @{@"car_made":@"Das Auto",\
                        @"car_model":@[@"Polo sedan 2014",@"Polo sedan 2015",@"Polo sedan GP 2015",@"Polo hatchback 2015",@"Polo hatchback 2016",@"Passat S 2016",@"Passat E 2016",@"Passat GP 2016",@"Tiguan 2015",@"Touareg 2015",@"Touareg GP 2015"]},\
                    @{@"car_made":@"Ford",\
                        @"car_model":@[@"Ecosport Trend",@"Ecosport Trend+",@"Ecosport Titanium",@"Everest 4x2 Trend",@"Everest 4x2 Titanium",@"Everest 4x4 Titanium",@"Fiesta Sport",@"Fiesta Titanium",@"Fiesta Fox Sport",@"Focus Ecoboost",@"Ranger XL 4x4",@"Ranger XLS 4x2",@"Ranger XLT 4x4",@"Ranger 4x2 Wildtrak",@"Ranger 4x4 Wildtrak"]},\
                    @{@"car_made":@"Honda",\
                        @"car_model":@[@"City",@"City Modulo",@"Civic",@"Civic Modulo",@"Accord",@"CR-V",@"CR-V TG",@"Odyssey"]},\
                    @{@"car_made":@"Hyundai",\
                        @"car_model":@[@"Grand i10 Base",@"Grand i10",@"i20 Active",@"Accent",@"Elantra",@"Sonata",@"Creta",@"Tucson 2WD",@"Tucson 2WD Special",@"SantaFe xăng 4x2",@"SantaFe xăng 4x4",@"SantaFe dầu 4x2",@"SantaFe dầu 4x4",@"Starex xăng",@"Starex diesel"]},\
                    @{@"car_made":@"KIA",\
                        @"car_model":@[@"Morning",@"Morning EX",@"Morning LX",@"Morning Si",@"Rio 4 cửa",@"Rio 5 cửa",@"Cerato 4 cửa",@"Cerato 5 cửa",@"Optima",@"Qouris",@"Soul",@"Soul sunroof",@"Rondo",@"Rondo Premium",@"Rondo diesel",@"Sorento 4x2 diesel",@"Sorento 4x2 xăng",@"Sorento 4x2 xăng hight",@"Sedona diesel",@"Sedona diesel hight",@"Sedona xăng",@"Sedona xăng hight"]},\
                    @{@"car_made":@"Land Rover",\
                        @"car_model":@[@"Rover Evoque",@"Range Rover",@"Range Rover Sport",@"Discovery Sport"]},\
                    @{@"car_made":@"Lexus",\
                        @"car_model":@[@"ES 250",@"ES 350",@"GS 350",@"LS 460L",@"NX 200t",@"RX 200t",@"RX 350",@"GX 460",@"LX 570"]},\
                    @{@"car_made":@"Mazda",\
                        @"car_model":@[@"Mazda 2",@"Mazda 2 hatchback",@"Mazda 3 sedan",@"Mazda 3 hatchback",@"Mazda 6 2.0",@"Mazda 6 2.5",@"CX-5 4x2 2.0",@"CX-5 4x2 2.5",@"CX-5 AWD",@"BT-50 4x2",@"BT-50 4x4"]},\
                    @{@"car_made":@"Mercedes-Benz",\
                        @"car_model":@[@"A200",@"A250",@"A45 AMG",@"C200",@"C250 Exclusive",@"C300 AMG",@"C300 Coupé",@"C63S AMG",@"E200",@"E200 Edition E",@"E250 AMG",@"S400L",@"S500L",@"S500 4 Matic Coupé",@"S600 Maybach",@"S63 AMG 4 Matic",@"CLA 200",@"CLA 250 4 Matic",@"CLA 45 AMG 4 Matic",@"CLS 400",@"CLS 500 4 Matic",@"GLA 200",@"GLA 250 4 Matic",@"GLA 45 AMG",@"GLC 250 4 Matic",@"GLC 300 AMG 4 Matic",@"GLE 400 4 Matic",@"GLE 400 4 Matic",@"GLE 400 4 Matic Exculsive",@"GLE 400 4 Matic Coupé"]},\
                    @{@"car_made":@"Mini Cooper",\
                        @"car_model":@[@"Cooper 3 cửa",@"Cooper S 3 cửa",@"Cooper 5 cửa",@"Cooper S 5 cửa",@"Cooper Cabriolet",@"Cooper S Cabriolet",@"Cooper Countryman",@"Cooper S Countryman",@"Cooper Clubman",@"Cooper S Clubman"]},\
                    @{@"car_made":@"Mitsubishi motors",\
                        @"car_model":@[@"Attrage MT Std",@"Attrage MT",@"Attrage CVT",@"Mirage",@"Outlander 2.0",@"Outlander 2.4",@"Outlander Sport",@"Outlander Sport Premium",@"Pajero Sport G 4x4",@"Pajero Sport G 4x2",@"Pajero Sport D 4x2",@"Pajero 3.0",@"Pajero 3.8",@"Triton 4x2",@"Triton 4x4"]},\
                    @{@"car_made":@"Nissan",\
                        @"car_model":@[@"Sunny XL",@"Sunny XV",@"Sunny SE",@"Teana",@"Teana SL",@"Juke",@"Navara E 4x2",@"Navara EL 4x2",@"Navara SL 4x4",@"Navara VL 4x4"]},\
                    @{@"car_made":@"Peugeot",\
                        @"car_model":@[@"Peugeot 208",@"Peugeot 308 Allure",@"Peugeot 308 GT Line",@"Peugeot 508",@"Peugeot 2008",@"Peugeot 3008"]},\
                    @{@"car_made":@"Porsche",\
                        @"car_model":@[@"Boxster",@"Boxster Black E",@"Boxster S",@"Boxster GTS",@"718 Boxster",@"718 Boxster S",@"Cayman",@"Cayman Black E",@"Cayman S",@"Cayman GTS",@"718 Cayman",@"718 Cayman S",@"911 Carrera",@"911 Carrera S",@"911 Carrera C",@"911 Carrera SC",@"911 Carrera 4",@"911 Carrera 4S",@"911 Carrera 4C",@"911 Carrera 4SC",@"911 Targa",@"911 Targa 4",@"911 Turbo",@"911 Turbo C",@"911 Turbo S",@"911 Turbo SC",@"911 GT3",@"911 GT3 RS",@"Panamera",@"Panamera 4",@"Panamera 4S",@"Panamera 4S Executive",@"Macan",@"Macan S",@"Macan Turbo",@"Macan GTS",@"Cayenne",@"Cayenne S",@"Cayenne GTS",@"Cayenne Turbo",@"Cayenne Turbo S"]},\
                    @{@"car_made":@"Renault",\
                        @"car_model":@[@"Logan",@"Sandero",@"Duster",@"Mégane",@"Latitude 2.0",@"Latitude 2.5",@"Koleos 4x2",@"Koleos 4x4"]},\
                    @{@"car_made":@"Subaru",\
                        @"car_model":@[@"Forester XT",@"Forester i-L",@"XV",@"Legacy 2.5",@"Legacy 3.6",@"Levorg GT-S",@"Outback 2.5",@"Outback 3.6",@"BR-Z",@"WRX STI"]},\
                    @{@"car_made":@"Suzuki",\
                        @"car_model":@[@"Swift",@"Swift Special",@"Ertiga",@"Vitara"]},\
                    @{@"car_made":@"Toyota",\
                        @"car_model":@[@"Yaris E",@"Yaris G",@"Vios E",@"Vios G CVT",@"Vios G 6MT",@"Altis G",@"Altis V",@"Camry E",@"Camry G",@"Camry Q",@"Innova E",@"Innova G",@"Innova V",@"Fortuner G",@"Fortuner V 4x2",@"Fortuner V 4x4",@"Fortuner TRD 4x2",@"Fortuner TRD 4x4",@"Land Cruiser Prado",@"Land Cruiser",@"Hilux E",@"Hilux G 4x4"]}]

#define CAR_SIZE @[@"4 chỗ", @"5 chỗ", @"7 chỗ", @"12 chỗ", @"16 chỗ", @"24 chỗ", @"40 chỗ", @"50 chỗ"]
#define CAR_TYPE @[@"Xe tự do", @"Xe taxi", @"Xe cưới", @"Xe hợp đồng", @"Xe tự lái", @"Xe tải chở hàng", @"Xe container"]
#define CAR_YEAR_OLD 10
#define TIME_UPDATE_LOCATE 30 //seconds
#define DISTANCE_MAX_GET_AROUND 100 // kilomet
#define TIME_LIMIT_GET_AROUND 3600 //seconds

#define TEXT_ALL @"Tất cả"

#endif /* Config_h */
