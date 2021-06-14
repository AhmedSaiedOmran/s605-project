<?php

use App\Models\Place;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    $places = Place::all();
    dd($places);
});
Route::get('/places', function () {
    $Places = Place::query();

    if(request()->id){
        $Places = $Places->where('id', request()->id);
    }
    if(request()->lon){
        $Places = $Places->where('lon', request()->lon);
    }
    if(request()->lat){
        $Places = $Places->where('lat', request()->lat);
    }
    if(request()->amenity){
        $Places = $Places->where('amenity',request()->amenity);
    }
    if(request()->name){
        $Places = $Places->where('name','like', '%' . request()->name . '%');
    }

    $Places = $Places->get();

    return $Places;
});
