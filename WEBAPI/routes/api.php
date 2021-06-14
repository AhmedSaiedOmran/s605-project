<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/
Route::get('/test', function () {
    Amqp::publish('get', '123' , ['queue' => 'test']);
});

Route::get('/places', 'APIPlacesController@index');
Route::post('/places', 'APIPlacesController@store');
Route::put('/places/{id}', 'APIPlacesController@update');
Route::delete('/places/{id}', 'APIPlacesController@destroy');

