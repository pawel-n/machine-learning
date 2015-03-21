{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}
{- |
Module      :  Data.ML.Scalar
Description :  Scalar functions.
Copyright   :  (c) Paweł Nowak
License     :  MIT

Maintainer  :  pawel834@gmail.com
Stability   :  experimental

This module exports pure scalar functions as models.
-}
module Data.ML.Scalar (
    Scalar(..),
    Over(..),
    Exp(..),
    Sqrt(..),
    Log(..),
    Sin(..),
    Cos(..),
    Asin(..),
    Atan(..),
    Acos(..),
    Sinh(..),
    Tanh(..),
    Cosh(..),
    Asinh(..),
    Atanh(..),
    Acosh(..),
    Sigmoid(..)
    ) where

import Control.Applicative
import Data.Bytes.Serial
import Data.Foldable
import Data.Functor.Identity
import Data.ML.Internal.Compose
import Data.ML.Internal.Scalar
import Data.ML.Model
import Data.ML.TH
import Data.Traversable
import Linear

-- | Applies a scalar model m over a structure f.
newtype Over f m a = Over (Compose f m a)
    deriving (Functor, Applicative, Foldable, Traversable, Additive, Metric)

instance (Serial1 f, Serial1 g) => Serial1 (Over f g) where
    serializeWith f (Over m) = serializeWith f m
    deserializeWith f = Over <$> deserializeWith f

instance (Applicative f, Model m, Input m ~ Scalar, Output m ~ Scalar)
         => Model (Over f m) where
    type Input (Over f m) = f
    type Output (Over f m) = f
    predict x (Over (Compose m)) = predict' <$> x <*> m
      where predict' x' m' = getScalar (predict (Scalar x') m')

mkPureModel [| exp |] "Exp"
mkPureModel [| sqrt |] "Sqrt"
mkPureModel [| log |] "Log"

mkPureModel [| sin |] "Sin"
mkPureModel [| tan |] "Tan"
mkPureModel [| cos |] "Cos"

mkPureModel [| asin |] "Asin"
mkPureModel [| atan |] "Atan"
mkPureModel [| acos |] "Acos"

mkPureModel [| sinh |] "Sinh"
mkPureModel [| tanh |] "Tanh"
mkPureModel [| cosh |] "Cosh"

mkPureModel [| asinh |] "Asinh"
mkPureModel [| atanh |] "Atanh"
mkPureModel [| acosh |] "Acosh"

sigmoid :: Floating f => f -> f
sigmoid x = 1 / (1 + exp (-x))

mkPureModel [| sigmoid |] "Sigmoid"