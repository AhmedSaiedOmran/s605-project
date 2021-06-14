<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Place;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Amqp;

class APIPlacesController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $statusCode = 200;
        $data = null;

        $Places = Place::query();

        if (request()->id) {
            $Places = $Places->where('id', request()->id);
        }
        if (request()->lon) {
            $Places = $Places->where('lon', request()->lon);
        }
        if (request()->lat) {
            $Places = $Places->where('lat', request()->lat);
        }
        if (request()->amenity) {
            $Places = $Places->where('amenity', request()->amenity);
        }
        if (request()->name) {
            $Places = $Places->where('name', 'like', '%' . request()->name . '%');
        }

        if (request()->all()) {
            $data = json_encode(request()->all());
        }

        $Places = $Places->get();

        $payload = [];
        $payload['timestamp'] = date('Y-m-d H:i:s');
        $payload['ip'] = request()->ip();
        $payload['data'] = $Places;
        $payload['statusCode'] = $statusCode;

        Amqp::publish('index', json_encode($payload), ['queue' => 'test']);

        return $Places;
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $statusCode = null;
        $data = null;

        $validator = Validator::make($request->all(), [
            'lon' => ["required", "regex:/^[-]?((((1[0-7][0-9])|([0-9]?[0-9]))\.(\d+))|180(\.0+)?)$/"],
            'lat' => ["required", "regex:/^[-]?(([0-8]?[0-9])\.(\d+))|(90(\.0+)?)$/"],
            'amenity' => ['required', Rule::in(['cafe', 'restaurant', 'fast_food'])],
            'name' => 'required',
        ]);


        if ($validator->fails()) {
            $statusCode = 400;
            $data = $validator->errors()->toJson();
        } else {
            $statusCode = 201;
            $data = $validator->validate();

            Place::create($data);
        }

        $payload = [];
        $payload['timestamp'] = date('Y-m-d H:i:s');
        $payload['ip'] = request()->ip();
        $payload['data'] = $data;
        $payload['statusCode'] = $statusCode;

        Amqp::publish('store', json_encode($payload), ['queue' => 'test']);

        return response($data, $statusCode)
            ->header('Content-Type', 'application/json');
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $statusCode = null;
        $data = null;

        $place = Place::find($id);

        if (!$place) {
            $statusCode = 404;
            $data['message'] = 'id not found';
        } else {
            $validator = Validator::make($request->all(), [
                'lon' => ["nullable", "regex:/^[-]?((((1[0-7][0-9])|([0-9]?[0-9]))\.(\d+))|180(\.0+)?)$/"],
                'lat' => ["nullable", "regex:/^[-]?(([0-8]?[0-9])\.(\d+))|(90(\.0+)?)$/"],
                'amenity' => ['nullable', Rule::in(['cafe', 'restaurant', 'fast_food'])],
                'name' => 'nullable',
            ]);

            if ($validator->fails()) {
                $statusCode = 400;
                $data = $validator->errors()->toJson();
            } else {
                $statusCode = 200;
                $data = $validator->validate();
                $place = $place->update($data);
            }
        }

        $payload = [];
        $payload['timestamp'] = date('Y-m-d H:i:s');
        $payload['ip'] = request()->ip();
        $payload['data'] = $data;
        $payload['statusCode'] = $statusCode;

        Amqp::publish('update', json_encode($payload), ['queue' => 'test']);

        return response($data, $statusCode)
            ->header('Content-Type', 'application/json');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $statusCode = null;
        $data = null;

        $place = Place::find($id);

        if (!$place) {
            $statusCode = 404;
            $data['message'] = 'id not found';
        } else {
            $statusCode = 200;
            $data['id'] = $id;

            $place = $place->delete();
        }

        $payload = [];
        $payload['timestamp'] = date('Y-m-d H:i:s');
        $payload['ip'] = request()->ip();
        $payload['data'] = $id;
        $payload['statusCode'] = $statusCode;

        Amqp::publish('destroy', json_encode($payload), ['queue' => 'test']);


        return response($data, $statusCode)
            ->header('Content-Type', 'application/json');
    }
}
