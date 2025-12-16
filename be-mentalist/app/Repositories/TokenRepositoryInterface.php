<?php

namespace App\Repositories;

interface TokenRepositoryInterface
{
    public function createToken(string $userId, string $name, array $abilities = ['*']): string;
    public function deleteToken(string $token): bool;
    public function validateToken(string $token): bool;
}